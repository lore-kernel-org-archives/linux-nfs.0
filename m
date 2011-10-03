Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.81]:58628 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755047Ab1JCMnJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Oct 2011 08:43:09 -0400
Date: Mon, 3 Oct 2011 08:43:05 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: Block layout status
Message-ID: <20111003124305.GA657@umich.edu>
References: <20110929165253.GC3724@umich.edu>
 <4E897E57.2000309@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E897E57.2000309@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  On 09/29/2011 07:52 PM, Jim Rees wrote:
  > Since the call doesn't seem to be happening, here's my status.
  > 
  > On 16 Sep I sent these bug fixes to Trond for 3.1:
  > 
  > Jim Rees (2):
  >   pnfsblock: fix size of upcall message     
  >   pnfsblock: fix return code confusion          
  > Peng Tao (3):
  >   pnfsblock: fix NULL pointer dereference                
  >   pnfsblock: fix writeback deadlock   
  >   pnfsblock: add missing rpc_put_mount and path_put
  > 
  > These are the ones I think are important enough, and low enough risk to
  > anyone else, that they should be considered for 3.1 even though it's late in
  > the release cycle.  They have not shown up upstream.  Trond?
  > 
  > On 22 Sep I sent these to Trond for 3.2.  I believe these are all in Benny's
  > tree now (sorry about that, Benny):
  > 
  > Jim Rees (2):
  >   pnfsblock: fix return code confusion
  >   pnfsblock: fix size of upcall message
  > Peng Tao (8):
  >   SUNRPC/NFS: make rpc pipe upcall generic
  >   pnfsblock: add missing rpc_put_mount and path_put
  >   pnfs: make _set_lo_fail generic
  > - pnfsblock: init pg_bsize properly
  >   pnfs: recoalesce when ld write pagelist fails
  >   pnfs: recoalesce when ld read pagelist fails
  >   pnfsblock: fix NULL pointer dereference
  >   pnfsblock: fix writeback deadlock
  
  Hi Jim I think this "writeback deadlock" should be sent for
  current 3.1 since surly it renders pnfsblock unusable. If you
  feel it has not been tested enough consider submitting it with
  CC: stable@. Because it should hit 3.1.x eventually. No?
  (While at it maybe some of the other clear FIXs above as well
   these that make it unusable)

I did send it to Trond (see the first list above).  If the patches from the
first list don't show up in 3.1 I will send them again with cc: stable.
