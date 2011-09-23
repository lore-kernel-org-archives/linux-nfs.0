Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:51601 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802Ab1IWIzf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 04:55:35 -0400
Message-ID: <4E7C4979.7010202@panasas.com>
Date: Fri, 23 Sep 2011 11:55:21 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: <tao.peng@emc.com>
CC: <rees@umich.edu>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>, <honey@citi.umich.edu>
Subject: Re: [PATCH 06/10] pnfsblock: init pg_bsize properly
References: <1316742617-14766-1-git-send-email-rees@umich.edu> <1316742617-14766-7-git-send-email-rees@umich.edu> <4E7C1766.1080501@panasas.com> <F19688880B763E40B28B2B462677FBF805C4952C79@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805C4952C79@MX09A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/23/2011 08:55 AM, tao.peng@emc.com wrote:
>>
>> If you want to get lazy about this patch and take the easy way out.
>> The least you can do is supply the same fix to that other place
>> that has the same bug.
> If I remember correctly, this patch should be dropped and Jim is working on a replacement, no?
> http://www.spinics.net/lists/linux-nfs/msg23596.html
> 

Thanks, Yes I thought so too, but it keeps coming up. It's already in Benny's
tree. At least for now it should be patching both places, til a better one
replaces it.

Boaz

> Cheers,
> Tao
