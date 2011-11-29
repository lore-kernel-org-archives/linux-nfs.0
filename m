Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:56862 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753308Ab1K2W7B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 17:59:01 -0500
Date: Tue, 29 Nov 2011 17:58:53 -0500
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Peng Tao <bergwolf@gmail.com>, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] pnfsblock patches
Message-ID: <20111129225853.GA8975@umich.edu>
References: <1322887583-2719-1-git-send-email-bergwolf@gmail.com>
 <4ED550DE.5030505@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4ED550DE.5030505@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:

  On 12/02/2011 08:46 PM, Peng Tao wrote:
  > Hi, Trond,
  > 
  > Following are some bugfix and improvements for blocklayout driver. All have been
  > sent to the list before and have been tested for several weeks.
  > 
  
  I never got 9 patches in the mail.
  
  I only have 1,3,4,5,6,7
  
  Do you have them on a gitweb, or re-post 2,8,9

1-7 are in benny's tree:

% git log --oneline -7 benny/pnfs-block
ec11faf pnfsblock: alloc short extent before submit bio
7c93c37 pnfsblock: clean up _add_entry
85e8c84 pnfsblock: remove rpc_call_ops from struct parallel_io
ab0c07d pnfsblock: set read/write tk_status to pnfs_error
60d5135 pnfsblock: move find lock page logic out of bl_write_pagelist
657c2f4 pnfsblock: acquire im_lock in _preload_range
e5b35df pnfsblock: cleanup bl_mark_sectors_init

I never saw 8,9 and can't find them in the list archive.
