Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:34338 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbbHXQDn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 12:03:43 -0400
Received: by widdq5 with SMTP id dq5so54894193wid.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 09:03:42 -0700 (PDT)
Subject: Re: [PATCH] svcrdma: remove dead code
To: Chuck Lever <chuck.lever@oracle.com>, Sagi Grimberg <sagig@mellanox.com>
References: <1440431931-24738-1-git-send-email-sagig@mellanox.com>
 <B705F885-C903-4780-82F8-30AD3EC88865@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Wise <swise@opengridcomputing.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55DB4064.8080404@dev.mellanox.co.il>
Date: Mon, 24 Aug 2015 19:03:48 +0300
MIME-Version: 1.0
In-Reply-To: <B705F885-C903-4780-82F8-30AD3EC88865@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/24/2015 7:01 PM, Chuck Lever wrote:
>
> On Aug 24, 2015, at 11:58 AM, Sagi Grimberg <sagig@mellanox.com> wrote:
>
>> No one is calling svc_rdma_fastreg. remove it.
>>
>> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
>
> There's already a patch to remove svc_rdma_fastreg() queued
> for 4.3 through Bruce's tree.

Didn't notice it over the list :\

Please ignore it then... sorry for the spam.
