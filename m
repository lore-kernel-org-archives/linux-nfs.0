Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35822 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbcDZU3L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:29:11 -0400
Subject: Re: [PATCH v2 17/18] xprtrdma: Remove ro_unmap() from all
 registration modes
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192307.3566.96703.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <571FCF8E.1060304@grimberg.me>
Date: Tue, 26 Apr 2016 23:29:02 +0300
MIME-Version: 1.0
In-Reply-To: <20160425192307.3566.96703.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now we have ro_unmap_safe() which sorta implies that there
is a non-safe unmap? Why not just keep it ro_umap?

Otherwise looks fine,

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
