From: Nick Wilson <njw@osdl.org>
Subject: Re: [PATCH] NFS: fix client hang due to race condition
Date: Thu, 7 Jul 2005 10:21:45 -0700
Message-ID: <20050707172145.GA5888@njw.pdx.osdl.net>
References: <482A3FA0050D21419C269D13989C611308539D6E@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, akpm@osdl.org,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dqa1c-0001GA-50
	for nfs@lists.sourceforge.net; Thu, 07 Jul 2005 10:19:00 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1Dqa1b-00006e-Le
	for nfs@lists.sourceforge.net; Thu, 07 Jul 2005 10:19:00 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611308539D6E@lavender-fe.eng.netapp.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Wed, Jul 06, 2005 at 07:11:25PM -0700, Lever, Charles wrote:
> > The flags field in struct nfs_inode is protected by the BKL.  The
> > following two code paths (there may be more, but my test program only
> > hits these two) modify the flags without obtaining the lock:
> > 
> >     nfs_end_data_update
> >     nfs_release
> >     nfs_file_release
> >     __fput
> >     fput
> >     filp_close
> >     sys_close
> >     syscall_call
> > 
> >     nfs_revalidate_mapping
> >     nfs_file_write
> >     do_sync_write
> >     vfs_write
> >     sys_write
> >     syscall_call
> > 
> > Running multiple instances of a simple program [1] that opens, writes
> > to, and closes NFS mounted files eventually results in the programs
> > hanging on an SMP system (see kernel .config [3]).
> > 
> > I've been testing this with 100 instances of the program:
> >     $ ./breaknfs 100 &
> > 
> > Usually within 10 minutes, all instances of breaknfs will hang.  They
> > disappear from the output of 'top' and there is no NFS 
> > activity between
> > the client and server.
> 
> [ sysrq output snipped... ]
> 
> > I've reproduced this bug on 2.6.11.10, 2.6.12-mm2, and 2.6.13-rc2.
> > 
> > With my patch against 2.6.13-rc2 below, I ran 100 instances 
> > of breaknfs
> > with this patch for 14 hours and I was unable to get the 
> > client to hang.
> 
> i agree this is a problem.
> 
> but instead of using heavyweight synchronization, why not convert the
> NFS_INO flags into atomic bitops?  i have a patch that does that; would
> need to be ported to the latest kernels and tested to see if it
> addresses the problem.
> 
> nick, are you interested in trying it out?

Sure.  Send it my way and I'll see if I can get it updated to the latest
kernels and test it out.

Nick


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
