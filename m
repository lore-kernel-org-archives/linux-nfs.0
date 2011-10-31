Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:53458 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933659Ab1JaSbo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 14:31:44 -0400
Date: Mon, 31 Oct 2011 14:31:31 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>,
        linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>,
        nfsv4 list <nfsv4@ietf.org>
Subject: Re: [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
Message-ID: <20111031183131.GA1925@umich.edu>
References: <1320074136-3087-1-git-send-email-bergwolf@gmail.com>
 <1320074136-3087-2-git-send-email-bergwolf@gmail.com>
 <1320076148.4714.4.camel@lade.trondhjem.org>
 <CA+a=Yy4L4GDsQL6hHG4DRLNPmvkMBpk4mW9ofWbQob+z2a1G2A@mail.gmail.com>
 <1320079501.4714.9.camel@lade.trondhjem.org>
 <4EAED61B.7030405@tonian.com>
 <1320082964.4714.23.camel@lade.trondhjem.org>
 <4EAEE173.80306@tonian.com>
 <1320085212.4714.48.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320085212.4714.48.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
