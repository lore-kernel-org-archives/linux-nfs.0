From: Chip Salzenberg <chip@pobox.com>
Subject: [pme@devphil.com: Bug#239158: Strange exportfs problems, fantastically unhelpful error message]
Date: Sun, 21 Mar 2004 10:35:15 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040321153515.GW29237@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B54z9-0006GD-IF
	for nfs@lists.sourceforge.net; Sun, 21 Mar 2004 07:35:35 -0800
Received: from topaz.cx
	([66.220.6.227] helo=mail.topaz.cx ident=mail)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B54z3-0007Wm-Vv
	for nfs@lists.sourceforge.net; Sun, 21 Mar 2004 07:35:30 -0800
Received: from home.topaz.cx ([66.58.78.58] helo=tytlal)
	by mail.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 1B54z1-0003wh-00
	for <nfs@lists.sourceforge.net>; Sun, 21 Mar 2004 07:35:27 -0800
Received: from chip by tytlal with local (Exim 4.30)
	id 1B54yp-000420-35
	for nfs@lists.sourceforge.net; Sun, 21 Mar 2004 10:35:15 -0500
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

This Debian bug report includes an exportfs problem which I suspect is
due to one export tree under the other, and an error message complaint
which I think is justified....

----- Forwarded message from Phil Edwards <pme@devphil.com> -----

Subject: Bug#239158: Strange exportfs problems, fantastically unhelpful error message
From: Phil Edwards <pme@devphil.com>
To: Debian Bug Tracking System <submit@bugs.debian.org>
Date: Sun, 21 Mar 2004 00:37:43 -0500

Package: nfs-kernel-server
Version: 1:1.0.6-1
Severity: normal

    [~]# cat /etc/exports
    /usr/local      fenric(ro,async) hreidmar(ro,async)
    /home           fenric(rw,sync) hreidmar(rw,sync)
    [~]# exportfs -v -r
    exporting hreidmar:/usr/local
    exporting fenric:/usr/local
    exporting hreidmar:/home
    exporting fenric:/home
    exporting hreidmar:/usr/local to kernel
    hreidmar:/usr/local: Invalid argument
    exporting fenric:/usr/local to kernel
    fenric:/usr/local: Invalid argument
    reexporting hreidmar:/home to kernel
    reexporting fenric:/home to kernel
    [~]#

I have no idea why the export fails.  If either line is commented, then
the export succeeds; presumably that's strong evidence of /something/,
but I don't know the nfs-kernel-server code at all and so can't say what.

My real complaint is that "Invalid argument" doesn't tell me a damn thing,
so I have no idea what to try next.


-- System Information:
Debian Release: testing/unstable
Architecture: i386
Kernel: Linux fenric 2.4.22-fenric3 #1 SMP Sun Oct 12 00:45:53 EDT 2003 i686
Locale: LANG=C, LC_CTYPE=C

Versions of packages nfs-kernel-server depends on:
ii  debconf                     1.4.7        Debian configuration management sy
ii  libc6                       2.3.2.ds1-11 GNU C Library: Shared libraries an
ii  libwrap0                    7.6-ipv6.1-3 Wietse Venema's TCP wrappers libra
ii  nfs-common                  1:1.0.6-1    NFS support files common to client
ii  sysvinit                    2.85-9       System-V like init.

-- debconf information:
  nfs-kernel-server/sync-default: 
  nfs-kernel-server/tcpwrappers-mountd: 




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
