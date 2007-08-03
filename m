From: Neil Brown <neilb@suse.de>
Subject: Re: [NFSD OOPS] 2.6.23-rc1-git10
Date: Fri, 3 Aug 2007 13:53:39 +1000
Message-ID: <18098.42691.783443.554197@notabene.brown>
References: <20070802171450.7c9b4af3@zeus.pccl.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Clayton <andrew@digital-domain.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGoEi-0002aW-7V
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 20:54:00 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGoEi-00068k-5j
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 20:54:04 -0700
In-Reply-To: message from Andrew Clayton on Thursday August 2
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday August 2, andrew@digital-domain.net wrote:
> Hi,
> 
> Got the following oopsen just now from 2.6.23-rc1-git10 on a 2
> processor Opteron with 2GB RAM. System is running 64bit Fedora Core 6.
> 
> nfsd is exporting directories from a XFS filesystem on top a software
> RAID 5 array comprising 3 x 250GB SATA disks using the sata_sil driver.
> 
> Amongst other things, users (about 12) home directories are
> automounted from it.
> 
> Some problems seem to start when I was experimenting with the
> stripe_cache_size of the md array. People could no longer run some apps
> and having general NFS issues. IIRC I had dropped the stripe_cache_size
> down from 8192 to 768 then I attempted to restart nfsd
> via /etc/rc.d/init.d/nfsd restart
> 
> I then got the Oopses and the machine locked up needing a power cycle.
> 
> 
> Aug  2 10:15:55 thor mountd[30048]: Caught signal 15, un-registering and exiting.
> Aug  2 10:15:55 thor nfsd[16390]: nfssvc: Setting version failed: errno 16 (Device or resource busy)
> Aug  2 10:15:56 thor kernel: lockd_down: lockd failed to exit, clearing pid
> Aug  2 10:15:56 thor kernel: nfsd: last server has exited
> Aug  2 10:15:56 thor kernel: nfsd: unexporting all filesystems
> Aug  2 10:15:56 thor kernel: ------------[ cut here ]------------
> Aug  2 10:15:56 thor kernel: kernel BUG at /home/andrew/src/linux-2.6/net/sunrpc/svc.c:488!

It seems you have found a race between shutting down and starting up
nfsd.
You md array was probably going very slowly due to playing with
stripe_cache_size, and that stretched things out long enough to loose
the race.

NFSD is shut down by something similar to
   killall nfsd

which sends signals to all the threads, but doesn't wait for them to
exit.
The first line in the log is mountd exiting.  nfsd should have all
been signalled at the same time.
The second line comes from the nfsd program trying to start up the
nfsd threads again, and getting an error because there were some
already running.
The third is a similar issue with lockd.

The 4th and 5th show the last thread exiting.   Only it isn't really
the last thread.  By this stage some more nfsd threads have started
up.  There was probably a backlog of requests as things were running
slowly so as soon as a new nfsd thread was started, it accepted a
connection and created a new temporary socket.  This would have been
after the thread that thought it was the last thread, thought it had
closed the last temp socket.
This caused the BUG.

As part of shutting down, the thread that thought it was last cleared
out the read-ahead info cache.  When the new threads tried to use it,
they all suffered general protection faults.

So clearly we need some proper locking around thread start-up and
shutdown.  We had previous relied on lock_kernel, but that isn't
really good enough for this.   I'll try to figure out the best way to
fix it.  Meanwhile, I doubt the problem will recur.

Thanks for the report.

NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
