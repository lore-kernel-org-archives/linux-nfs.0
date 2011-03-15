From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] RPC: return task->tk_status from
 rpc_wait_for_completion_task() in case of successfull task completion
Date: Tue, 15 Mar 2011 10:26:55 -0400
Message-ID: <1300199215.14093.1.camel@lade.trondhjem.org>
References: <20110315141951.16564.72417.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	linux-kernel@vger.kernel.org, bfields@fieldses.org,
	skinsbursky@openvz.org
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755263Ab1COO1r convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 10:27:47 -0400
In-Reply-To: <20110315141951.16564.72417.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-03-15 at 17:20 +0300, Stanislav Kinsbursky wrote:
> Some NFS and NLM routines doesn't check RPC task tk_status if
> rpc_wait_for_completion_task() returned 0 but have to.

Examples please. I'm not aware of any such cases.

Cheers
   Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

