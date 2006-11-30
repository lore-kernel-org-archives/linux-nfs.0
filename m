From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: NFS hang
Date: Thu, 30 Nov 2006 06:08:34 -0600
Message-ID: <1164888514.19697.37.camel@crusty.rchland.ibm.com>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
	<Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
	<Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
	<1164655027.5727.5.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611271929220.10489@nacho.alt.net>
	<1164657487.5727.12.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611272110270.24703@nacho.alt.net>
	<1164663614.10787.21.camel@zod.rchland.ibm.com>
	<1164664453.5727.44.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chris Caputo <ccaputo@alt.net>, Frank Filz <ffilz@us.ibm.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GpkhD-0001Oj-Be
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 04:07:19 -0800
Received: from e35.co.us.ibm.com ([32.97.110.153])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GpkhC-0003LT-ES
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 04:07:20 -0800
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com
	[9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAUC6rKt009795
	for <nfs@lists.sourceforge.net>; Thu, 30 Nov 2006 07:06:53 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	kAUC6qDm543532
	for <nfs@lists.sourceforge.net>; Thu, 30 Nov 2006 05:06:52 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	kAUC6p6S027022
	for <nfs@lists.sourceforge.net>; Thu, 30 Nov 2006 05:06:52 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1164664453.5727.44.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2006-11-27 at 16:54 -0500, Trond Myklebust wrote:
> On Mon, 2006-11-27 at 15:40 -0600, Josh Boyer wrote:
> > On Mon, 2006-11-27 at 21:22 +0000, Chris Caputo wrote:
> > > On Mon, 27 Nov 2006, Trond Myklebust wrote:
> > > > On Mon, 2006-11-27 at 19:33 +0000, Chris Caputo wrote:
> > > > > On Mon, 27 Nov 2006, Trond Myklebust wrote:
> > > > > > On Mon, 2006-11-27 at 19:09 +0000, Chris Caputo wrote:
> > > > > > > -		if (!RPC_IS_QUEUED(task))
> > > > > > > -			continue;
> > > > > > > -		rpc_clear_running(task);
> > > > > > > +		queue = task->u.tk_wait.rpc_waitq;
> > > > > >
> > > > > > NACK... There is no guarantee that task->u.tk_wait has any meaning here.
> > > > > > Particularly not so in the case of an asynchronous task, where the
> > > > > > storage is shared with the work_struct.
> > > > >
> > > > > Yikes.  Would you suggest I move the lock outside of the union and try
> > > > > again?
> > > >
> > > > No. There is no way this can work. You would need something that
> > > > guarantees that the task stays queued while you are taking the queue
> > > > lock.
> > > >
> > > > Have you instead tried Christophe Saout's patch (see attachment)?
> > >
> > > Thank you for the suggestion.  With 65 minutes of uptime so far, Saout's
> > > November 5th patch is looking good.  For reference, normally I see the
> > > race happen in under 15 minutes.
> > >
> > > I'll report back if any problems develop.  This machine is an outgoing
> > > newsfeed server and so it pounds on NFS client routines 24x7.
> >
> > Would the race condition that Chris described potentially lead to the
> > stack trace I originally posted?  If so, I can try to test this patch
> > out myself.
> 
> Possibly. It is worth trying.

We've been testing this patch in our kernel and it looks good.  The
tests have run for 2 days and 13 hours so far, which is longer than
previous attempts.  I would suggest adding this to upstream (if it isn't
already), and possibly even the stable release.

josh


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
