
import React, { useState } from 'react';
import { LayoutDashboard, ShoppingCart, Package, TrendingUp, BookOpen, DollarSign, Menu, X, BarChart3, Settings, Wallet, Users, Gift, LogOut, Sun, Moon, Truck, ClipboardList, Instagram } from 'lucide-react';
import Metrics from './Metrics';
import { useStore } from '../hooks/useStore';

export default function Layout({ children, activeTab, onTabChange, onLogout, userRole = 'admin' }) {
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
    const { theme, toggleTheme, isSyncing, socialLinks, syncError } = useStore();

    const navItems = [
        { id: 'sales', label: 'Ventas', icon: TrendingUp },
        { id: 'cash', label: 'Caja y Turnos', icon: DollarSign },
        { id: 'inventory', label: 'Stock', icon: Package },
        { id: 'catalog', label: 'Catálogo', icon: BookOpen },
        { id: 'metrics', label: 'Métricas', icon: BarChart3 },
        { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
        { id: 'settings', label: 'Config', icon: Settings },
    ];

    return (
        <div className="min-h-screen bg-gray-50 dark:bg-slate-950 flex flex-col md:flex-row transition-colors duration-300">
            {/* Sidebar Desktop */}
            <aside className="hidden md:flex flex-col w-20 bg-slate-900 border-r border-slate-800 text-white min-h-screen shadow-xl z-20 items-center">
                <div className="p-4 border-b border-slate-800 flex flex-col items-center gap-3">
                    <img src="/logo_lafamilia.jpg" alt="Logo" className="w-10 h-10 object-contain rounded-md" title="La Familia" />

                    {/* Botón de Sincronización Manual */}
                    <button
                        onClick={() => window.location.reload()}
                        className={`group p-2 rounded-full transition-all duration-500 ${isSyncing ? 'bg-brand-500/20 rotate-180' : syncError ? 'bg-red-500/20' : 'bg-slate-800 hover:bg-brand-600'}`}
                        title={syncError ? `Error: ${syncError}` : "Sincronizar ahora (F5)"}
                    >
                        <Truck size={16} className={`${isSyncing ? 'text-brand-500 animate-bounce' : syncError ? 'text-red-500' : 'text-slate-400 group-hover:text-white'}`} />
                    </button>

                    <div className="flex flex-col items-center gap-1">
                        <div className={`w-2 h-2 rounded-full ${isSyncing ? 'bg-amber-500' : syncError ? 'bg-red-500 animate-pulse' : 'bg-green-500'}`}></div>
                        <span className={`text-[7px] font-black uppercase tracking-widest leading-none ${syncError ? 'text-red-500' : 'text-slate-500'}`}>
                            {isSyncing ? 'Sync' : syncError ? 'Error' : 'Cloud'}
                        </span>
                    </div>
                </div>
                <nav className="flex-1 p-4 space-y-2">
                    {navItems.map((item) => {
                        const Icon = item.icon;
                        return (
                            <button
                                key={item.id}
                                onClick={() => onTabChange(item.id)}
                                className={`w-full flex flex-col items-center justify-center gap-1 px-2 py-3 rounded-xl transition-all duration-200 group ${activeTab === item.id
                                    ? 'bg-brand-600 text-white shadow-lg shadow-brand-900/20'
                                    : 'text-slate-400 hover:bg-slate-800 hover:text-white'
                                    } `}
                                title={item.label}
                            >
                                <Icon size={24} className={activeTab === item.id ? 'text-white' : 'text-slate-500 group-hover:text-white'} />
                                <span className="text-[10px] font-medium hidden md:block text-center leading-tight">{item.label}</span>
                            </button>
                        );
                    })}
                </nav>
                <div className="p-4 border-t border-slate-800 space-y-4">
                    <button
                        onClick={onLogout}
                        className="w-full flex flex-col items-center justify-center gap-1 px-2 py-3 rounded-xl transition-all duration-200 text-slate-400 hover:bg-red-600 hover:text-white group"
                        title="Cerrar Sesión"
                    >
                        <LogOut size={24} className="text-slate-500 group-hover:text-white" />
                        <span className="text-[10px] font-medium">Salir</span>
                    </button>
                </div>
                <div className="p-4 border-t border-slate-800 text-xs text-slate-500 text-center">
                    v5.8.0 &copy; 2026
                </div>
            </aside>

            {/* Mobile Header */}
            <div className="md:hidden bg-slate-900 text-white p-4 flex justify-between items-center sticky top-0 z-50 shadow-md">
                <div className="flex items-center gap-2">
                    <span className="font-bold text-lg">Seitu Manager</span>
                    {isSyncing && (
                        <div className="flex items-center gap-1 bg-brand-500/10 px-2 py-0.5 rounded-full border border-brand-500/20">
                            <div className="w-1.5 h-1.5 bg-brand-500 rounded-full animate-ping"></div>
                        </div>
                    )}
                </div>
                <button onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}>
                    {isMobileMenuOpen ? <X /> : <Menu />}
                </button>
            </div>

            {/* Mobile Menu Overlay */}
            {isMobileMenuOpen && (
                <div className="md:hidden absolute top-16 left-0 right-0 bg-slate-900 border-b border-slate-800 z-40 p-4 shadow-xl">
                    <nav className="space-y-2">
                        {navItems.map((item) => (
                            <button
                                key={item.id}
                                onClick={() => {
                                    onTabChange(item.id);
                                    setIsMobileMenuOpen(false);
                                }}
                                className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg ${activeTab === item.id ? 'bg-brand-600 text-white' : 'text-slate-400'
                                    } `}
                            >
                                <item.icon size={20} />
                                {item.label}
                            </button>
                        ))}
                    </nav>
                    <button
                        onClick={() => {
                            onLogout();
                            setIsMobileMenuOpen(false);
                        }}
                        className="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-red-400 hover:bg-red-600 hover:text-white transition-all"
                    >
                        <LogOut size={20} />
                        Cerrar Sesión
                    </button>
                </div>
            )}

            {/* Main Content */}
            <main className="flex-1 p-4 md:p-8 overflow-y-auto">
                <div className="max-w-7xl mx-auto space-y-6">
                    {children}
                </div>
            </main>
        </div>
    );
}
