From: elijah wright <elw@stderr.org>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Fri, 7 May 2004 17:27:48 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0405071727090.29926@illuminati.stderr.org>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu>
 <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org>
 <20040506230055.GC26968@polop.usc.edu> <20040507182543.GA27341@fieldses.org>
 <20040507213811.GL30964@polop.usc.edu> <Pine.LNX.4.58.0405071651080.11315@illuminati.stderr.org>
 <20040507221701.GN30964@polop.usc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMDov-0005gH-FQ
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 15:27:53 -0700
Received: from illuminati.stderr.org ([63.246.8.57] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BMDov-0006ox-6x
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 15:27:53 -0700
To: Garrick Staples <garrick@usc.edu>
In-Reply-To: <20040507221701.GN30964@polop.usc.edu>
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



oops.  sorry, i had it in my head that those were in mount commands rather
than exportfs commands.  no clue what i was thinking.

elijah


> > > [root@hpc-fs3 root]# mount /dev/vgtest/lvtest /mnt/test
> > > [root@hpc-fs3 root]# exportfs -o rw,no_subtree_check,no_root_squash,async 10.125.0.0/16:/mnt/test
> > > [root@hpc-fs3 root]# exportfs -u 10.125.0.0/16:/mnt/test
> >
> > those sure are some weird IP addresses ( .0.0? ) ...
>
> 10.125.0.0/16 is network notation.  It means all IPs from 10.125.0.0 through
> 10.125.255.255.
>
>


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
