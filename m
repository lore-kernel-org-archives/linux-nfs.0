From: Chip Salzenberg <chip@pobox.com>
Subject: [sdg@dir.bg: Bug#239230: nfs-kernel-server: exportfs fails to export a dir with a ``#'' (pound sign) in name even when ``#'' is given as \043]
Date: Sun, 21 Mar 2004 12:13:25 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040321171325.GX29237@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B56W7-00082G-Bz
	for nfs@lists.sourceforge.net; Sun, 21 Mar 2004 09:13:43 -0800
Received: from topaz.cx
	([66.220.6.227] helo=mail.topaz.cx ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B56W6-00048R-OQ
	for nfs@lists.sourceforge.net; Sun, 21 Mar 2004 09:13:42 -0800
Received: from home.topaz.cx ([66.58.78.58] helo=tytlal)
	by mail.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 1B56W3-0004At-00
	for <nfs@lists.sourceforge.net>; Sun, 21 Mar 2004 09:13:40 -0800
Received: from chip by tytlal with local (Exim 4.30)
	id 1B56Vp-0004QH-Tz
	for nfs@lists.sourceforge.net; Sun, 21 Mar 2004 12:13:25 -0500
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is an interesting one.  I hope the bug is entirely in user space....

----- Forwarded message from Stoyan Genov <sdg@dir.bg> -----

Subject: Bug#239230: nfs-kernel-server: exportfs fails to export a dir with a ``#'' (pound sign) in name even when ``#'' is given as \043
From: Stoyan Genov <sdg@dir.bg>
To: Debian Bug Tracking System <submit@bugs.debian.org>
Date: Sun, 21 Mar 2004 18:54:14 -0500
X-Mailer: reportbug 2.48

Package: nfs-kernel-server
Version: 1:1.0.6-1
Severity: normal

According to exports(5):
[snip]
	Blank  lines  are  ignored.  A pound sign ("#") introduces a comment to
	the end of the line. Entries may be continued across newlines  using  a
	backslash.  If an export name contains spaces it should be quoted using
	double quotes. You can also specify spaces or other  unusual  character
	in  the export name using a backslash followed by the character code as
	three octal digits.
[snip]

However:

fin-rst:~# uname -a
Linux fin-rst 2.6.3-1-686 #2 Tue Feb 24 20:24:38 EST 2004 i686 GNU/Linux
fin-rst:~# ls -ld '/weird-dir-#'
drwxr-xr-x    2 root     root           48 Mar 20 20:21 /weird-dir-#
fin-rst:~# grep -v '^#' /etc/exports
/weird-dir-\043 *(ro)
fin-rst:~# exportfs -r
exportfs: /etc/exports [4]: No 'sync' or 'async' option specified for export "*:/weird-dir-#".
  Assuming default behaviour ('sync').
  NOTE: this default has changed from previous versions

fin-rst:~# showmount -e localhost
Export list for localhost:
/weird-dir- (everyone)
           ^
-----------| note that the # is missing

fin-rst:~# mount 'localhost:/weird-dir-#' /mnt
mount: localhost:/weird-dir-# failed, reason given by server: Permission denied

In my humble opinion, either the documentation must be fixed to
explicitly state you cannot export a directory with a pound sign in its
name, or the parser of /etc/exports be fixed ( latter is better :-) )

Best Regards,
Stoyan Genov


-- System Information:
Debian Release: testing/unstable
  APT prefers testing
  APT policy: (500, 'testing')
Architecture: i386 (i686)
Kernel: Linux 2.6.3-1-686
Locale: LANG=C, LC_CTYPE=C

Versions of packages nfs-kernel-server depends on:
ii  debconf                     1.4.16       Debian configuration management sy
ii  libc6                       2.3.2.ds1-11 GNU C Library: Shared libraries an
ii  libwrap0                    7.6-ipv6.1-3 Wietse Venema's TCP wrappers libra
ii  nfs-common                  1:1.0.6-1    NFS support files common to client
ii  sysvinit                    2.85-9       System-V like init.

-- debconf information excluded




----- End forwarded message -----

-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
