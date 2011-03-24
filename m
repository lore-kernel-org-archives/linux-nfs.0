Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35699 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933899Ab1CXRGK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2011 13:06:10 -0400
Message-ID: <4D8B79FF.8060906@panasas.com>
Date: Thu, 24 Mar 2011 19:06:07 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
CC: Fred Isaman <iisaman@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 11/12] NFSv4.1: layoutcommit
References: <AANLkTi=S+gQER_upORoaK6WSMp8++25W6pTDpR7MD9Ec@mail.gmail.com>
In-Reply-To: <AANLkTi=S+gQER_upORoaK6WSMp8++25W6pTDpR7MD9Ec@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-03-24 16:45, William A. (Andy) Adamson wrote:
> Hi Benny
> 
> int sync is used because the struct writeback_control->sync_mode (an
> enum) is assigned.

Then the compiler will do the assignment into bool once (I hope it
optimizes for the enum values which are {0,1}) and thereafter use the
bool value.

Benny

> 
> -->Andy
> 
>>> +pnfs_layoutcommit_inode(struct inode *inode, int sync)
>>
>> "bool sync" makes more sense
