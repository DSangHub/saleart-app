export const metadata = {
  title: 'SaleArt.app',
  description: 'Reusable e-ink sale signs controlled by the app',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
