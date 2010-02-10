From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [pnfs] [PATCH 2/6] pnfsd: fix NFS4ERR_BADIOMODE in layoutget
Date: Wed, 10 Feb 2010 10:26:24 +0200
Message-ID: <4B726DB0.4000301@panasas.com>
References: <1265737357-9405-1-git-send-email-andros@netapp.com>	<1265737357-9405-2-git-send-email-andros@netapp.com>	<1265737357-9405-3-git-send-email-andros@netapp.com> <4B71A360.3090302@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: andros@netapp.com, linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57860 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752760Ab0BJI01 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2010 03:26:27 -0500
In-Reply-To: <4B71A360.3090302@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/09/2010 08:03 PM, Benny Halevy wrote:
> Thanks!
> 
> I'm committing everything but patch 6/6 for now.
> Please check again the !CONFIG_PNFSD case.
> I don't see any problem.
> 
> Benny
> 

Don't we have other places that need a patch like the one I sent
to exofs?

Boaz
