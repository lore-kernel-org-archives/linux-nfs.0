From: trond.myklebust@fys.uio.no
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Mon, 1 Mar 2004 19:48:06 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <35336.207.214.87.84.1078166886.squirrel@webmail.uio.no>
References: <20040301081456.37082.qmail@web12823.mail.yahoo.com>
    <34574.207.214.87.84.1078162727.squirrel@webmail.uio.no>
    <40437AE4.4030407@lehman.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Shantanu Goel" <sgoel01@yahoo.com>,
     "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>,
     "Charles Lever" <Charles.Lever@netapp.com>,
     "Olaf Kirch" <okir@suse.de>,"Greg Banks" <gnb@melbourne.sgi.com>,
     nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AxsXh-0002DS-GJ
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 10:53:29 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AxsC3-0006Al-MS
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 10:31:07 -0800
To: "Shantanu Goel" <Shantanu.Goel@lehman.com>
In-Reply-To: <40437AE4.4030407@lehman.com>
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

På må , 01/03/2004 klokka 10:03, skreiv Shantanu Goel:
> Not a matter of being difficult.  It won't  fix the underlying issue 
that a single heavy writer will block other async writes for a looong 
time.  Here's the scenario.  dd makes a huge bunch of nfs_strategy() 
calls and fills up the async queue.  Another process comes along and 
writes 128K then closes the file.  Before the close, it will call 
nfs_strategy() which will queue async writes after all the ones from 
dd.  So, effectively, how quickly dd completes will determine how 
quickly this process can return from close.  What you need is a way to 
tell the scheduler that the async writes from the latter process are not

> the same as the ones from dd.  Using the pid is one such approach, 
though as you pointed out probably not the best one.  Another would be 
the cookie approach.  Each rpc_message has a cookie field.  The NFS 
layer sets the cookie to be the inode.  The scheduler implements the 
multiple priority queues but at the same priority level, round-robins 
between different cookies.  Does that clear it up?

Not entirely.

Simple round robin is not going to play well with NFSv2 style write
gathering on the server. Nor will it really work too efficiently with
standard readahead.
How about instead doing round-robin on blocks of, say, 16 requests per
cookie (which is the current maximum readahead value)? That should allow
the server some efficiency on block operations without sacrificing your
fairness criterion.

Note: to avoid having to revamp rpc_call_sync() to take a cookie all the
time, you could have rpc_init_task() set the default cookie to be a
pointer to the thread's task_struct. For the particular case of
read/write ops, the NFS layer can modify that cookie to be a pointer to
the inode.

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
