From: Chris Horn <irrationality@comcast.net>
Subject: NFS configuration problem?
Date: Mon, 11 Aug 2003 19:02:00 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308111902.00900.irrationality@comcast.net>
Reply-To: irrationality@comcast.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc12.comcast.net ([204.127.202.56])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19mLg6-00063t-00
	for <nfs@lists.sourceforge.net>; Mon, 11 Aug 2003 16:02:14 -0700
Received: from snozberry. ([192.168.0.2] helo=snozberry.beefstew.net)
	by caverns.beefstew.net with esmtp (Exim 3.36 #1 (Debian))
	id 19mLeQ-0002PP-00
	for <nfs@lists.sourceforge.net>; Mon, 11 Aug 2003 19:00:30 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Package: nfs-kernel-server
Version: 1:1.0.5-1
Severity: normal

caverns - Debian file server
snozberry - Debian workstation

I can't seem to mount anything on caverns from snozberry.  The error
that I get in /var/log/syslog on caverns is:

Aug  7 22:02:29 caverns rpc.mountd: snozberry. has non-inet addr 

I am almost positive I have BIND set up correctly, though, as I can
mount NFS shares on snozberry from caverns. Caverns is the DNS server,
though, so maybe I do have something mis-configured?  If NFS is trying
to do a dig on "snozberry." then that won't work because it's missing the
domain (beefstew.net).

I manually upgraded just nfs-kernel-server and nfs-common on caverns to
1.0.5-1 after reading bug #202987.  I, too, see mountd die on caverns
after my mount attempt from snozberry.  I don't know whether this is
related to the problem above.


Please help.
chris.

-- System Information:
Debian Release: testing/unstable
Architecture: i386
Kernel: Linux caverns 2.4.18 #1 Wed May 28 12:22:24 EDT 2003 i686
Locale: LANG=C, LC_CTYPE=C

Versions of packages nfs-kernel-server depends on:
ii  debconf                     1.2.35       Debian configuration management sy
ii  libc6                       2.3.1-16     GNU C Library: Shared libraries an
ii  libwrap0                    7.6-ipv6.1-3 Wietse Venema's TCP wrappers libra
ii  nfs-common                  1:1.0.5-1    NFS support files common to client
ii  sysvinit                    2.85-4.1     System-V like init.

-- debconf information:
* nfs-kernel-server/sync-default: 
  nfs-kernel-server/tcpwrappers-mountd: 

This information may be of use.

(root) caverns:/usr/src
# dig -x 192.168.0.2

; <<>> DiG 9.2.2 <<>> -x 192.168.0.2
;; global options:  printcmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 4489
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;2.0.168.192.in-addr.arpa.      IN      PTR

;; ANSWER SECTION:
2.0.168.192.in-addr.arpa. 604800 IN     PTR     snozberry.beefstew.net.

;; AUTHORITY SECTION:
0.168.192.in-addr.arpa. 604800  IN      NS      dns.beefstew.net.0.168.192.in-addr.arpa.

;; Query time: 29 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Aug  7 23:17:27 2003
;; MSG SIZE  rcvd: 109


=========================================

(root) caverns:/usr/src
# dig snozberry.            

; <<>> DiG 9.2.2 <<>> snozberry.
;; global options:  printcmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 21316
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;snozberry.                     IN      A

;; AUTHORITY SECTION:
.                       7936    IN      SOA     a.root-servers.net. nstld.verisign-grs.com. 2003080701 1800 900 604800 86400

;; Query time: 6 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Aug  7 23:17:42 2003
;; MSG SIZE  rcvd: 102

=========================================

(root) caverns:/usr/src
# dig snozberry.beefstew.net

; <<>> DiG 9.2.2 <<>> snozberry.beefstew.net
;; global options:  printcmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 26708
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

;; QUESTION SECTION:
;snozberry.beefstew.net.                IN      A

;; ANSWER SECTION:
snozberry.beefstew.net. 604800  IN      A       192.168.0.2

;; AUTHORITY SECTION:
beefstew.net.           604800  IN      NS      dns.beefstew.net.

;; ADDITIONAL SECTION:
dns.beefstew.net.       604800  IN      A       192.168.0.4

;; Query time: 7 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Aug  7 23:17:54 2003
;; MSG SIZE  rcvd: 90



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
