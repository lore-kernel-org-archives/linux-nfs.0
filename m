From: elijah wright <elw@stderr.org>
Subject: Re: kernel panic
Date: Mon, 27 Sep 2004 08:41:07 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.61.0409270839000.29028@illuminati.stderr.org>
References: <I4P0P0$FC87B9CC694AB887F0DC180A63B5222F@libero.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: NFS NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CBvmh-0006Lw-V2
	for nfs@lists.sourceforge.net; Mon, 27 Sep 2004 06:43:19 -0700
Received: from illuminati.stderr.org ([63.246.8.57] ident=postfix)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CBvmg-000883-Gc
	for nfs@lists.sourceforge.net; Mon, 27 Sep 2004 06:43:19 -0700
To: "lp4u@inwind.it" <lp4u@inwind.it>
In-Reply-To: <I4P0P0$FC87B9CC694AB887F0DC180A63B5222F@libero.it>
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


> I've a s3c2410 board (BAST architecture), I've compilated a kernel 
> 2.6.8.1 with patch 2.6.9-rc2 e patch 2.6.9-rc2-bk12. But the board don't 
> start with NFS (with kernel 2.4.26, yes). My configuration is:

> # CONFIG_ARTHUR is not set
> CONFIG_CMDLINE="root=/dev/nfs rw nfsroot=143.225.229.44:/board ip=dhcp init/bin/bash
> console=ttySAC0"

> NET: Registered protocol family 17
> IP-Config: No network devices available.

this looks like your problem to me.  where's your network?  =)

elijah


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
