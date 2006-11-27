From: Chris Caputo <ccaputo@alt.net>
Subject: Re: NFS hang
Date: Mon, 27 Nov 2006 21:22:48 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0611272110270.24703@nacho.alt.net>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
	<Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
	<Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
	<1164655027.5727.5.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611271929220.10489@nacho.alt.net>
	<1164657487.5727.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilz@us.ibm.com>, nfs@lists.sourceforge.net,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GonwD-0008Vc-Lk
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 13:22:53 -0800
Received: from nacho.alt.net ([207.14.113.18])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GonwE-0007xs-R8
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 13:22:55 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1164657487.5727.12.camel@lade.trondhjem.org>
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

On Mon, 27 Nov 2006, Trond Myklebust wrote:
> On Mon, 2006-11-27 at 19:33 +0000, Chris Caputo wrote:
> > On Mon, 27 Nov 2006, Trond Myklebust wrote:
> > > On Mon, 2006-11-27 at 19:09 +0000, Chris Caputo wrote:
> > > > -		if (!RPC_IS_QUEUED(task))
> > > > -			continue;
> > > > -		rpc_clear_running(task);
> > > > +		queue = task->u.tk_wait.rpc_waitq;
> > > 
> > > NACK... There is no guarantee that task->u.tk_wait has any meaning here.
> > > Particularly not so in the case of an asynchronous task, where the
> > > storage is shared with the work_struct.
> > 
> > Yikes.  Would you suggest I move the lock outside of the union and try 
> > again?
> 
> No. There is no way this can work. You would need something that
> guarantees that the task stays queued while you are taking the queue
> lock.
> 
> Have you instead tried Christophe Saout's patch (see attachment)?

Thank you for the suggestion.  With 65 minutes of uptime so far, Saout's 
November 5th patch is looking good.  For reference, normally I see the 
race happen in under 15 minutes.

I'll report back if any problems develop.  This machine is an outgoing 
newsfeed server and so it pounds on NFS client routines 24x7.

Chris

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
