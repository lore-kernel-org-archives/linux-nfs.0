From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] nfs: fix some issues in nfs41_proc_reclaim_complete()
Date: Thu, 22 Apr 2010 21:38:54 +0200
Message-ID: <20100422193854.GA29093@bicker>
References: <20100422092839.GI29647@bicker> <4BD04D66.80809@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andy Adamson <andros@netapp.com>,
	Alexandros Batsakis <batsakis@netapp.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38124 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757373Ab0DVTj7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Apr 2010 15:39:59 -0400
In-Reply-To: <4BD04D66.80809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 22, 2010 at 04:21:42PM +0300, Benny Halevy wrote:
> Dan, thanks for sending the fix.
> For the sake of dprintk, how about doing this instead:
> 

Good point.

Acked-by: Dan Carpenter <error27@gmail.com>

regards,
dan carpenter
