Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:45389 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565Ab2BVMvO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Feb 2012 07:51:14 -0500
Message-ID: <4F44E4B8.4010405@parallels.com>
Date: Wed, 22 Feb 2012 16:51:04 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFS: Ensure struct nfs_client holds a reference to
 the net namespace
References: <1329637821-6986-1-git-send-email-Trond.Myklebust@netapp.com> <1329637821-6986-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1329637821-6986-2-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

19.02.2012 11:50, Trond Myklebust пишет:
> Otherwise we have no guarantee that the net namespace won't just
> disappear from underneath us once the task that created it
> is destroyed.

I'm not 100% sure, but holding net reference on NFS client level looks redundant 
to me, because nfs_client holds net reference on transport level (xprt_net).
But this is not an objection: code looks clearer and safer with this patch.

-- 
Best regards,
Stanislav Kinsbursky
