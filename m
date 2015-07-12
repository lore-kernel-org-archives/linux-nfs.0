Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35709 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbbGLOmP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jul 2015 10:42:15 -0400
Received: by wiga1 with SMTP id a1so48731626wig.0
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 07:42:13 -0700 (PDT)
Subject: Re: [PATCH v1 06/12] xprtrdma: Always provide a write list when
 sending NFS READ
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204237.26247.297.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55A27CC3.9080601@dev.mellanox.co.il>
Date: Sun, 12 Jul 2015 17:42:11 +0300
MIME-Version: 1.0
In-Reply-To: <20150709204237.26247.297.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/9/2015 11:42 PM, Chuck Lever wrote:
> The client has been setting up a reply chunk for NFS READs that are
> smaller than the inline threshold. This is not efficient: both the
> server and client CPUs have to copy the reply's data payload into
> and out of the memory region that is then transferred via RDMA.
>
> Using the write list, the data payload is moved by the device and no
> extra data copying is necessary.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Reviewed-By: Sagi Grimberg <sagig@mellanox.com>
