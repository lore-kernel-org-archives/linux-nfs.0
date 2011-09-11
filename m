Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:37615 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094Ab1IKRVh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Sep 2011 13:21:37 -0400
Date: Sun, 11 Sep 2011 13:21:34 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 0/3] pnfs private workqueue, and two cleanups
Message-ID: <20110911172134.GB5195@merit.edu>
References: <1315676495-3689-1-git-send-email-rees@umich.edu>
 <4E6CDB3D.2050702@tonian.com>
 <4E6CDC1C.7030507@tonian.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E6CDC1C.7030507@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

  On 2011-09-11 09:01, Benny Halevy wrote:
  > I merged the patches as well as my two SQUASHMEs
  > under pnfs-all-3.1-rc4-2011-09-11
  
  hit "Send" too soon...
  In fact I merged all the patches in linux-pnfs-blk/for-benny
  Including my SQUASHMEs, I merged the following patches:
  
  fd06920 SUNRPC/NFS: make rpc pipe upcall generic
  0359f0e pNFS: introduce pnfs private workqueue
  fee4dab SQUASHME: pnfs: simplify and clean up pnfsiod workqueue
  ab93fb1 SQUASHME: pnfs: do pnfsiod_start before registering layout drivers
  9d904b1 pNFS: make _set_lo_fail generic
  be077c0 pnfsblock: init pg_bsize properly
  3c03366 pNFS: recoalesce when ld write pagelist fails
  a4e8a6e pNFS: recoalesce when ld read pagelist fails

These last two are still being worked on, but I don't think it will hurt
anyone not using blocklayout to have them in your repo.  Thanks.

Also see the small whitespace cleanup I just sent.
