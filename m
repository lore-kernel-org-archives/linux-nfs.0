From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/4] NFS: Set security flavor default for NFSv2/3 mounts like other defaults
Date: Thu, 26 Jun 2008 16:53:15 -0400
Message-ID: <FC077622-BD91-4524-92F1-7469A209BAC1@oracle.com>
References: <20080624202913.3366.44867.stgit@ellison.1015granger.net> <20080624203345.3366.31456.stgit@ellison.1015granger.net> <1214509684.7503.2.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:55368 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221AbYFZUyU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2008 16:54:20 -0400
In-Reply-To: <1214509684.7503.2.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 26, 2008, at 3:48 PM, Trond Myklebust wrote:
> On Tue, 2008-06-24 at 16:33 -0400, Chuck Lever wrote:
>> Set the default security flavor when we set the other mount option  
>> default
>> values.  After this change, only the legacy user-space mount path  
>> needs to
>> set the NFS_MOUNT_SECFLAVOUR flag.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/nfs/super.c |   22 +++++-----------------
>> 1 files changed, 5 insertions(+), 17 deletions(-)
>>
>
> Does not apply to the devel tree...

Looks like you are missing three patches I recently sent.  I'll post  
them now.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
