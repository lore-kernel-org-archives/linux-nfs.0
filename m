From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: NFS hang
Date: Mon, 27 Nov 2006 15:40:13 -0600
Message-ID: <1164663614.10787.21.camel@zod.rchland.ibm.com>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
	<Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
	<Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
	<1164655027.5727.5.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611271929220.10489@nacho.alt.net>
	<1164657487.5727.12.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611272110270.24703@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilz@us.ibm.com>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GooDG-0001t0-JG
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 13:40:30 -0800
Received: from e5.ny.us.ibm.com ([32.97.182.145])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GooDG-0004eb-Kk
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 13:40:32 -0800
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kARLeFKC028650
	for <nfs@lists.sourceforge.net>; Mon, 27 Nov 2006 16:40:15 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	kARLe56M188332
	for <nfs@lists.sourceforge.net>; Mon, 27 Nov 2006 16:40:05 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	kARLe4S2008649
	for <nfs@lists.sourceforge.net>; Mon, 27 Nov 2006 16:40:05 -0500
To: Chris Caputo <ccaputo@alt.net>
In-Reply-To: <Pine.LNX.4.64.0611272110270.24703@nacho.alt.net>
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

On Mon, 2006-11-27 at 21:22 +0000, Chris Caputo wrote:
> On Mon, 27 Nov 2006, Trond Myklebust wrote:
> > On Mon, 2006-11-27 at 19:33 +0000, Chris Caputo wrote:
> > > On Mon, 27 Nov 2006, Trond Myklebust wrote:
> > > > On Mon, 2006-11-27 at 19:09 +0000, Chris Caputo wrote:
> > > > > -		if (!RPC_IS_QUEUED(task))
> > > > > -			continue;
> > > > > -		rpc_clear_running(task);
> > > > > +		queue = task->u.tk_wait.rpc_waitq;
> > > >
> > > > NACK... There is no guarantee that task->u.tk_wait has any meaning here.
> > > > Particularly not so in the case of an asynchronous task, where the
> > > > storage is shared with the work_struct.
> > >
> > > Yikes.  Would you suggest I move the lock outside of the union and try
> > > again?
> >
> > No. There is no way this can work. You would need something that
> > guarantees that the task stays queued while you are taking the queue
> > lock.
> >
> > Have you instead tried Christophe Saout's patch (see attachment)?
> 
> Thank you for the suggestion.  With 65 minutes of uptime so far, Saout's
> November 5th patch is looking good.  For reference, normally I see the
> race happen in under 15 minutes.
> 
> I'll report back if any problems develop.  This machine is an outgoing
> newsfeed server and so it pounds on NFS client routines 24x7.

Would the race condition that Chris described potentially lead to the
stack trace I originally posted?  If so, I can try to test this patch
out myself.

josh


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
