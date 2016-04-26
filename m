Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32923 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624AbcDZUqt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:46:49 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 17/18] xprtrdma: Remove ro_unmap() from all registration modes
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <571FCF8E.1060304@grimberg.me>
Date: Tue, 26 Apr 2016 16:46:38 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2AB2B747-1D14-4885-9CEA-23104AC2A379@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net> <20160425192307.3566.96703.stgit@manet.1015granger.net> <571FCF8E.1060304@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 26, 2016, at 4:29 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> Now we have ro_unmap_safe() which sorta implies that there
> is a non-safe unmap? Why not just keep it ro_umap?

Er, I would find that confusing too.

How about name it ro_unmap_slow(), but it's for asynchronous
cases too.


> Otherwise looks fine,
> 
> Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



