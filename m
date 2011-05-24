Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:44891 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932147Ab1EXOiK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 10:38:10 -0400
Message-ID: <4DDBC2B4.9040305@panasas.com>
Date: Tue, 24 May 2011 17:37:40 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SQUASHME: objio read/write patch: Bugs fixes
References: <4DDA8C3D.5080706@panasas.com> <1306168626-11463-1-git-send-email-bhalevy@panasas.com> <4DDAB94C.6070407@panasas.com> <4DDBAE2B.2060705@panasas.com>
In-Reply-To: <4DDBAE2B.2060705@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/24/2011 04:10 PM, Benny Halevy wrote:
> 
> This hunk doesn't apply cleanly, as in the latest version
> we pass gfp_flags, not GFP_KERNEL.
> 
>>  	if (!objio_seg)
>>  		return -ENOMEM;
>>  

Please don't do anything. I'm just now sending a clean
SQUASHME set

Please talk to me

Boaz]
