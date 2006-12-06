From: Chris Caputo <ccaputo@alt.net>
Subject: Re: NFS hang
Date: Wed, 6 Dec 2006 18:36:01 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0612061829100.22584@nacho.alt.net>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
	<Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
	<Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
	<1164655027.5727.5.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611271929220.10489@nacho.alt.net>
	<1164657487.5727.12.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611272110270.24703@nacho.alt.net>
	<Pine.LNX.4.64.0611302108180.16297@nacho.alt.net>
	<Pine.LNX.4.64.0612010337210.4621@nacho.alt.net>
	<1164948671.5761.12.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0612010905240.4621@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilz@us.ibm.com>, nfs@lists.sourceforge.net,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gs1cm-00013p-VS
	for nfs@lists.sourceforge.net; Wed, 06 Dec 2006 10:36:09 -0800
Received: from nacho.alt.net ([207.14.113.18])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Gs1co-0006z3-0d
	for nfs@lists.sourceforge.net; Wed, 06 Dec 2006 10:36:10 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <Pine.LNX.4.64.0612010905240.4621@nacho.alt.net>
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

On Fri, 1 Dec 2006, Chris Caputo wrote:
> On Thu, 30 Nov 2006, Trond Myklebust wrote:
> > On Fri, 2006-12-01 at 04:20 +0000, Chris Caputo wrote:
> > > On Thu, 30 Nov 2006, Chris Caputo wrote:
> > > > I am not sure if this is related, but at just over 3 days of uptime with 
> > > > 2.6.19-rc6 and the Saout patch, I had this happen:
> > > > 
> > > > ---
> > > > BUG: unable to handle kernel NULL pointer dereference at virtual address 00000028
> > > >  printing eip:
> > > > c029cf64
> > > > EIP is at call_start+0x5c/0x6f
> > > 
> > > I believe the above is the following line in clnt.c:call_start():
> > > 
> > >   clnt->cl_stats->rpccnt++;
> > > 
> > > So call_start() was called with a NULL task->tk_client.
> > > 
> > > Similar result with 2.6.19...
> > > 
> > > BUG: unable to handle kernel NULL pointer dereference at virtual address 00000008
> > >  printing eip:
> > > c029ef8e
> > > EIP is at xprt_reserve+0x28/0x119
> > > 
> > > In this one xprt.c:xprt_reserve() is I believe crashing at:
> > > 
> > >   spin_lock(&xprt->reserve_lock);
> > > 
> > > due to a NULL task->tk_xprt.
> > > 
> > > Ideas on whether this is related to the Saout sched race patch or if this 
> > > is something else entirely?
> > 
> > I suspect that it is related, but not the same race. I've identified a
> > couple of other possible race conditions, mainly to do with the fact
> > that nothing prevents an rpc_task from being freed while you are inside
> > rpc_wake_up_task(). Could you try applying both the attached patches,
> > and see if that helps?
> 
> I compiled 2.6.19 with your patches in addition to the Saout patch and a 
> test is now in progress.

With:

  linux-2.6.19-001-fix_rpc_wakeup_race.dif
  linux-2.6.19-002-cleanup_rpc_wakeup.dif
  linux-2.6.19-003-rpc_wakeup_fix_pot_race.dif

My 2.6.19 test machine is now at 5 days 9+ hours of uptime with no 
problems and the following number of RPC calls:

  Client rpc stats:
  calls      retrans    authrefrsh
  1314188163   2344       0

Previously a problem happened within between a few hours and up to 3 days 
of uptime, so this may be progress.

I'll leave the machine running and report back any problems.

Thanks,
Chris

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
