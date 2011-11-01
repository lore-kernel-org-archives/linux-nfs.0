Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:43311 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170Ab1KAPAn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Nov 2011 11:00:43 -0400
From: <david.noveck@emc.com>
To: <welch@panasas.com>, <rees@umich.edu>, <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, <nfsv4@ietf.org>
Date: Tue, 1 Nov 2011 10:59:49 -0400
Subject: RE: [nfsv4] [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
Message-ID: <5DEA8DB993B81040A21CF3CB332489F6862F3318@MX31A.corp.emc.com>
References: <1320074136-3087-1-git-send-email-bergwolf@gmail.com>
	<1320074136-3087-2-git-send-email-bergwolf@gmail.com>
	<1320076148.4714.4.camel@lade.trondhjem.org>
	<CA+a=Yy4L4GDsQL6hHG4DRLNPmvkMBpk4mW9ofWbQob+z2a1G2A@mail.gmail.com>
	<1320079501.4714.9.camel@lade.trondhjem.org>	<4EAED61B.7030405@tonian.com>
	<1320082964.4714.23.camel@lade.trondhjem.org>	<4EAEE173.80306@tonian.com>
	<1320085212.4714.48.camel@lade.trondhjem.org>
	<20111031183131.GA1925@umich.edu>
 <DA636AC7BF798243A4007D3AA0B3D3A733FDCD61@seabiscuit.int.panasas.com>
In-Reply-To: <DA636AC7BF798243A4007D3AA0B3D3A733FDCD61@seabiscuit.int.panasas.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As I recall, the primary focus of CB_RECALL ANY was in dealing with recall of delegations. 

With delegations the server is in no position to, if needs to get some number back, pick
ones that are not being used, since it is in the nature of delegations that the client may
be using them with great benefit with the server not hearing anything about them.  So the
logic there was that if the client didn't do the picking and just did nothing the server would 
have to pick for himself, and would almost certainly do a poor job, and the client might not
like the server's choices.

For other recallable objects, the logic my be different.  In the case of layouts, the 
data servers will know if they are being used but the MDFS will not.  So if the client won't
act on this, and the server picks badly, it can't say "there was no way I could have picked 
better ones" as it can with delegations.


The spec should make it clear whether the client is at fault in this case or the server 
should have done its best by incorporating data server information on layout use, but ....

   The chances of client and server implementors agreeing on this are fairly low.
   So ambiguity/confusion on this issue may persist for a while.

-----Original Message-----
From: nfsv4-bounces@ietf.org [mailto:nfsv4-bounces@ietf.org] On Behalf Of Welch, Brent
Sent: Monday, October 31, 2011 5:43 PM
To: Jim Rees; Trond Myklebust
Cc: linux-nfs@vger.kernel.org; nfsv4 list
Subject: Re: [nfsv4] [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY

CB_RECALL_ANY was added based on Panasas experience with its own protocols.   When you have
100's (or 1000's) of clients and millions of files for which you maintain state, it is
very much worth optimizing how the server can reclaim this state.
	Brent

-----Original Message-----
From: nfsv4-bounces@ietf.org [mailto:nfsv4-bounces@ietf.org] On Behalf Of Jim Rees
Sent: Monday, October 31, 2011 11:32 AM
To: Trond Myklebust
Cc: linux-nfs@vger.kernel.org; nfsv4 list
Subject: Re: [nfsv4] [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY

Trond Myklebust wrote:

  I don't necessarily disagree with what you are saying, but I have yet to
  see a single server side implementation of CB_RECALL_ANY, let alone any
  numbers that indicate performance or responsiveness problems resulting
  from our existing client-side implementation.
  
  I therefore find it hard to understand why optimising this particular
  code is such a high priority, or why a patch that is adding per-file
  layoutreturns to initiate_bulk_draining() is going to help anything at
  all.

Testing between the linux block layout client and the EMC block layout
server revealed a deadlock when the server had handed out some number of
layouts and couldn't hand out any more.  So now the EMC block layout server
implements CB_RECALL_ANY.  So yes, this solves a real world problem, and
yes, there is a server that implements this.

We had some discussions at the time, and I don't remember if those were on
the linux-nfs list or in some other forum.  We decided that the client was
in the best position to decide which layouts were no longer needed, so we
needed some way for the server to tell the client to return some layouts
without specifying which ones.  CB_RECALL_ANY seemed custom-made for this
purpose, so we used it.

I don't think it would be appropriate for the server to recall all layouts
when it only needs some of them back.
_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4
_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

