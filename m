From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Debian Bug#235886: nfs-kernel-server inducing load of 8-9 with no good reason for Linux 2.6 clients
Date: Mon, 22 Mar 2004 11:25:11 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16478.12903.581002.87570@notabene.cse.unsw.edu.au>
References: <20040318210943.GK3605@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5DGU-0002bj-FJ
	for nfs@lists.sourceforge.net; Sun, 21 Mar 2004 16:26:02 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1B5DGT-0002g2-6Z
	for nfs@lists.sourceforge.net; Sun, 21 Mar 2004 16:26:01 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Mon, 22 Mar 2004 11:25:19 +1100
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Thursday March 18
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

On Thursday March 18, chip@pobox.com wrote:
> 
> Neil (or someone), what should I tell this user?
> 

"use tcp" might be a good answer.... especially if it works :-)

NeilBrown

> 
> ----- Forwarded message from "Steinar H. Gunderson" <sgunderson@bigfoot.com> -----
> 
> Subject: Bug#235886: nfs-kernel-server inducing load of 8-9 with no good reason for Linux 2.6 clients
> From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
> To: Debian Bug Tracking System <submit@bugs.debian.org>
> Date: Wed, 03 Mar 2004 00:41:21 +0100
> X-Mailer: reportbug 1.50
> 
> Package: nfs-kernel-server
> Version: 1:1.0-2woody1
> Severity: important
> 
> It appears that from time to time, our NFS servers (both 2.4 and 2.6
> servers, but both running woody) seem to go into giant loads with almost
> no traffic (ie. 20-30 connections, but almost no file activity, as
> confirmed by tcpdump). This is typically in the 7-8-9 range, and the
> clients in question seem to hang almost indefinitely (like 20 minutes
> for a simple ls). However, top shows no processes wanting CPU time, so
> it almost looks like some kind of I/O starvation problem.
> 
> In addition, we seem to get strange errors like:
> 
>   00:16:32.330039 129.241.93.186 > 129.241.93.30: icmp: ip reassembly time exceeded [tos 0xc0] 
> 
> (.30 is the NFS server, .186 is one of the NFS clients)
>   
> Something is clearly wrong here; stopping nfs-kernel-server makes the
> load drop to zero almost immediately, and substituting nfs-user-server for
> nfs-kernel-server also fixes the problem. The servers in question are
> also NFS clients, but there are no stale mounts and we aren't using NFS
> re-export.
> 
> These problems seem to coincide with the rollout of Linux 2.6.x (seen
> the problem with both 2.6.1 and 2.6.3) on the clients, so it seems
> plausible that something in the Linux 2.6 client is triggering the NFS
> kernel server code. I'm a bit unsure if I should file this on
> nfs-kernel-server or on a kernel package; feel free to reassign as
> needed.
> 
> -- System Information
> Debian Release: 3.0
> Architecture: i386
> Kernel: Linux cassarossa 2.4.25 #1 SMP Wed Feb 18 22:46:21 CET 2004 i686
> Locale: LANG=en_US, LC_CTYPE=en_US.ISO8859-1
> 
> Versions of packages nfs-kernel-server depends on:
> ii  debconf                    1.2.35        Debian configuration management sy
> ii  libc6                      2.2.5-11.5    GNU C Library: Shared libraries an
> ii  libwrap0                   7.6-9         Wietse Venema's TCP wrappers libra
> ii  nfs-common                 1:1.0-2woody1 NFS support files common to client
> 
> ----- End forwarded message -----
> 
> -- 
> Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
> "I wanted to play hopscotch with the impenetrable mystery of existence,
>     but he stepped in a wormhole and had to go in early."  // MST3K
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
