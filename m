Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43042 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932087Ab3DYP7E convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2013 11:59:04 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS loop on 3.4.39
Date: Thu, 25 Apr 2013 15:59:01 +0000
Message-ID: <1366905541.6812.18.camel@leira.trondhjem.org>
References: <OF6F031A84.8897519B-ONC1257B4E.002D1BA3-C1257B4E.002DBED0@LocalDomain>
		 <OFA06D4153.317BAF9A-ONC1257B4F.002F597B-C1257B4F.003AC46C@transmode.se>
	 <1366126613.12556.18.camel@leira.trondhjem.org>
				 <OFB2555ACD.CF7424A9-ONC1257B4F.00613A5E-C1257B4F.006908CE@transmode.se>
	 <1366150010.27817.8.camel@leira.trondhjem.org>
			 <OF97D68E61.A3C35530-ONC1257B51.0043E567-C1257B51.00450958@LocalDomain>
	 <OFF8AA22C1.D96F08FD-ONC1257B52.003B6FD9-C1257B52.003BEEF9@LocalDomain>
	 <OFAB88709A.0F45CAFB-ONC1257B56.0049D3CA-C1257B56.004AE572@transmode.se>
	 <1366725123.35524.2.camel@leira.trondhjem.org>
		 <OF940BEB3A.13ADB6E5-ONC1257B56.004D412D-C1257B56.004E3C54@tran
 <1366726687.35524.6.camel@leira.trondhjem.org>
	 <OFDF20F4D8.12606C1E-ONC1257B57.00486945-C1257B57.0048EA91@LocalDomain>
	 <OF036BF424.501B6F08-ONC1257B58.005491D2-C1257B58.00555225@transmode.se>
In-Reply-To: <OF036BF424.501B6F08-ONC1257B58.005491D2-C1257B58.00555225@transmode.se>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-04-25 at 17:31 +0200, Joakim Tjernlund wrote:
> Joakim Tjernlund/Transmode wrote on 2013/04/24 15:16:26:
> > 
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote on 2013/04/23 
> 16:18:07:
> > > 
> > > On Tue, 2013-04-23 at 16:14 +0200, Joakim Tjernlund wrote:
> > > > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote on 2013/04/23 
> > > > 15:52:06:
> > > > > 
> > > > > On Tue, 2013-04-23 at 15:38 +0200, Joakim Tjernlund wrote:
> > > > > > So, it happened again. Just when hitting search on 
> bugs.gentoo.org in 
> > > > > > firefox 17.0.3
> > > > > > 
> > > > > > This time I got a NFS loop with NFS4ERR_BAD_STATEID looping over 
> and 
> > > > over
> > > > > > again and FF was hung. Not posting the logs as it does not 
> appear to
> > > > > > do any good. Nothing in dmesg either.
> > > > > > 
> > > > > > Noticed this patch on the NFS list:
> > > > > >   http://marc.info/?l=linux-nfs&m=136643651710066&w=2
> > > > > > I wonder if that could be a potential cure and if so, could it 
> be
> > > > > > backported to 3.4?
> > > > > 
> > > > > It is in the testing branch on
> > > > > 
> > > > >   http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=summary
> > > > > 
> > > > > if you want to try it out. I'm not planning on backporting 
> anything that
> > > > > hasn't been labelled with a Cc: stable in that branch.
> > > > 
> > > > Well, we won't use tip of linus tree in production so there is
> > > > little point to use your testing branch. However it looks like a 
> trivial
> > > > backport so I can test it on my client easily.
> > > 
> > > The point of testing would not be to discover if you can use Linus' 
> tree
> > > in production, but rather to see if the problem is already fixed
> > > upstream. If it is, we can bisect to figure out which patch is the 
> fix.
> > > 
> > > > Even the NFS server if required, is the above referenced patch for
> > > > NFS client/server or both? Any chance this is the culprit?
> > > 
> > > That's a client patch.
> 
> > Tried 3.4.41+above nfs patch and also 3.8.8, they both have the
> > NFS loop problem.
> > 
> > Now I am at your 
> http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=summary, 
> > testing branch
> > With any luck the error will show soon.
> > 
> > Question though the loop I see, could it be a NFS server bug ?
> > If so it does matter what I do on my client I guess.
> 
> Ran http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=summary, testing 
> branch
> for a day without problem.
> 
> Then I backed to 3.4.41 + 
>   http://marc.info/?l=linux-nfs&m=136643651710066&w=2 +
>   http://marc.info/?l=linux-nfs&m=136674349127504&w=2
> this morning, been using all day without problem. It is a good start
> but not conclusive yet.
> 
> Is http://marc.info/?l=linux-nfs&m=136674349127504&w=2 supposed to
> fix my type of problem?

No. That's a follow up patch to commit
92b40e93849e29f9ca661de6442bb66282738bf7 (NFSv4: Use the open stateid if
the delegation has the wrong mode).


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
