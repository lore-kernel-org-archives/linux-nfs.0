From: Chris Caputo <ccaputo@alt.net>
Subject: Re: NFS hang
Date: Fri, 1 Dec 2006 04:20:04 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0612010337210.4621@nacho.alt.net>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
	<Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
	<Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
	<1164655027.5727.5.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611271929220.10489@nacho.alt.net>
	<1164657487.5727.12.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611272110270.24703@nacho.alt.net>
	<Pine.LNX.4.64.0611302108180.16297@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilz@us.ibm.com>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gpzsa-0000U5-SZ
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 20:20:05 -0800
Received: from nacho.alt.net ([207.14.113.18])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Gpzsc-00059u-34
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 20:20:06 -0800
To: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <Pine.LNX.4.64.0611302108180.16297@nacho.alt.net>
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

On Thu, 30 Nov 2006, Chris Caputo wrote:
> On Mon, 27 Nov 2006, Chris Caputo wrote:
> > On Mon, 27 Nov 2006, Trond Myklebust wrote:
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
> I am not sure if this is related, but at just over 3 days of uptime with 
> 2.6.19-rc6 and the Saout patch, I had this happen:
> 
> ---
> BUG: unable to handle kernel NULL pointer dereference at virtual address 00000028
>  printing eip:
> c029cf64
> EIP is at call_start+0x5c/0x6f

I believe the above is the following line in clnt.c:call_start():

  clnt->cl_stats->rpccnt++;

So call_start() was called with a NULL task->tk_client.

Similar result with 2.6.19...

BUG: unable to handle kernel NULL pointer dereference at virtual address 00000008
 printing eip:
c029ef8e
EIP is at xprt_reserve+0x28/0x119

In this one xprt.c:xprt_reserve() is I believe crashing at:

  spin_lock(&xprt->reserve_lock);

due to a NULL task->tk_xprt.

Ideas on whether this is related to the Saout sched race patch or if this 
is something else entirely?

Chris

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
