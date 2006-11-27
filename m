From: Chris Caputo <ccaputo@alt.net>
Subject: Re: NFS hang
Date: Mon, 27 Nov 2006 21:46:39 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0611272141430.24703@nacho.alt.net>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
	<Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
	<Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
	<1164655027.5727.5.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611271929220.10489@nacho.alt.net>
	<1164657487.5727.12.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611272110270.24703@nacho.alt.net>
	<1164663614.10787.21.camel@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilz@us.ibm.com>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GooJJ-0002Xo-NN
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 13:46:45 -0800
Received: from nacho.alt.net ([207.14.113.18])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GooJI-0006F6-UA
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 13:46:47 -0800
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
In-Reply-To: <1164663614.10787.21.camel@zod.rchland.ibm.com>
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

On Mon, 27 Nov 2006, Josh Boyer wrote:
> On Mon, 2006-11-27 at 21:22 +0000, Chris Caputo wrote:
> > On Mon, 27 Nov 2006, Trond Myklebust wrote:
> > > On Mon, 2006-11-27 at 19:33 +0000, Chris Caputo wrote:
> > > > On Mon, 27 Nov 2006, Trond Myklebust wrote:
> > > > > On Mon, 2006-11-27 at 19:09 +0000, Chris Caputo wrote:
> > > > > > -		if (!RPC_IS_QUEUED(task))
> > > > > > -			continue;
> > > > > > -		rpc_clear_running(task);
> > > > > > +		queue = task->u.tk_wait.rpc_waitq;
> > > > >
> > > > > NACK... There is no guarantee that task->u.tk_wait has any meaning here.
> > > > > Particularly not so in the case of an asynchronous task, where the
> > > > > storage is shared with the work_struct.
> > > >
> > > > Yikes.  Would you suggest I move the lock outside of the union and try
> > > > again?
> > >
> > > No. There is no way this can work. You would need something that
> > > guarantees that the task stays queued while you are taking the queue
> > > lock.
> > >
> > > Have you instead tried Christophe Saout's patch (see attachment)?
> > 
> > Thank you for the suggestion.  With 65 minutes of uptime so far, Saout's
> > November 5th patch is looking good.  For reference, normally I see the
> > race happen in under 15 minutes.
> > 
> > I'll report back if any problems develop.  This machine is an outgoing
> > newsfeed server and so it pounds on NFS client routines 24x7.
> 
> Would the race condition that Chris described potentially lead to the
> stack trace I originally posted?  If so, I can try to test this patch
> out myself.

Yes.  Your stack showed that your process was waiting for data to be read 
via NFS.  It is possible that this bug resulted in your read request being 
lost forever and thus your process hung forever.  And any other processes 
which then attempted to read the same data would also hang.  It's 
contagious.  :-)

Chris

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
