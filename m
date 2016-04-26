Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32891 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314AbcDZUEe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:04:34 -0400
Subject: Re: [PATCH v2 07/18] xprtrdma: Allow Read list and Reply chunk
 simultaneously
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192145.3566.55207.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <571FC9CF.6090002@grimberg.me>
Date: Tue, 26 Apr 2016 23:04:31 +0300
MIME-Version: 1.0
In-Reply-To: <20160425192145.3566.55207.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> The code that encodes each chunk list is now completely contained in
> its own function. There is some code duplication, but the trade-off
> is that the overall logic should be more clear.

Looks like more than "some code duplication", but if it helps
to have a simpler logic I'm ok...

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
