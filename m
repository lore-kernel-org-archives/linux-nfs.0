From: trond.myklebust@fys.uio.no
Subject: RE: [PATCH 2.6.3] Add write throttling to NFS client
Date: Mon, 1 Mar 2004 08:49:52 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1050.207.214.87.84.1078127392.squirrel@webmail.uio.no>
References: <20040301065511.29682.qmail@web12824.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>,
     "Charles Lever" <Charles.Lever@netapp.com>,
     "Olaf Kirch" <okir@suse.de>,"Greg Banks" <gnb@melbourne.sgi.com>,
     nfs@lists.sourceforge.net,Shantanu.Goel@lehman.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AxiFj-0007yl-VH
	for nfs@lists.sourceforge.net; Sun, 29 Feb 2004 23:54:15 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AxiBi-0004HI-R2
	for nfs@lists.sourceforge.net; Sun, 29 Feb 2004 23:50:07 -0800
To: "Shantanu Goel" <sgoel01@yahoo.com>
In-Reply-To: <20040301065511.29682.qmail@web12824.mail.yahoo.com>
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

På su , 29/02/2004 klokka 22:55, skreiv Shantanu Goel:

> You must have missed the tk_proc field I added to
> rpc_task.  It is explicitly initialized with the pid
> of the initiating process in rpc_init_task.

...and my point is "what makes you think that the process that calls
rpc_init_task has anything to do with the process that scheduled the read
or write?"

> Did I miss some other place where the tasks are created?

I repeat: most asynchronous rpc_tasks are NOT scheduled by the kernel
thread that created them. See the pdflush task. It doesn't create *ANY*
read or writes, but it schedules a lot of them.

> Isn't the RPC layer supposed to be generic and not
> privy to request internals?  Wouldn't knowlege of
> inodes qualify as such?  If we wish to preserve this
> quality, other than the process id, how else would you
> distinguish one request from another?  The only way I
> can think of is if the upper layers can pass down a
> cookie in rpc_task.  In the NFS case it would be the
> inode. Is that what you have in mind?

Yes, or alternatively, just give the tasks a numeric priority. That's all
we do for real tasks after all...

> You do raise an interesting issue with regards to
> memory pressure.  I'll run some tests with low memory
> to see if this patch survives it.  Keep in mind
> though, any writebacks initiated by pdflush/kswapd
> will be tagged with their respective pid's and run in
> parallel.  The will not block behind those of the
> original process.

EXACTLY, and that's the whole problem...

They will all be tagged with the pid of pdflush/kswapd, and hence will all
be in a single queue. That means that those tasks have a de-facto lower
priority than competing synchronous tasks (which will have different pids,
and hence only have to compete with the head of the queue) whereas we'd
actually like them to have a *higher* priority 'cos they are needed to
deal with memory pressure.

Cheers,
  Trond


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
