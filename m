Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37979 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbcCHRxO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Mar 2016 12:53:14 -0500
Received: by mail-wm0-f41.google.com with SMTP id l68so38396462wml.1
        for <linux-nfs@vger.kernel.org>; Tue, 08 Mar 2016 09:53:13 -0800 (PST)
Subject: Re: [PATCH v3 05/11] xprtrdma: Do not wait if ib_post_send() fails
To: Chuck Lever <chuck.lever@oracle.com>, anna.schumaker@netapp.com
References: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org>
 <20160304162801.13590.89343.stgit@oracle120-ib.cthon.org>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56DF1186.3030303@dev.mellanox.co.il>
Date: Tue, 8 Mar 2016 19:53:10 +0200
MIME-Version: 1.0
In-Reply-To: <20160304162801.13590.89343.stgit@oracle120-ib.cthon.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/03/2016 18:28, Chuck Lever wrote:
> If ib_post_send() in ro_unmap_sync() fails, the WRs have not been
> posted, no completions will fire, and wait_for_completion() will
> wait forever. Skip the wait in that case.
>
> To ensure the MRs are invalid, disconnect.

How does that help to ensure that?

The first wr that failed and on will leave the
corresponding MRs invalid, and the others will be valid
upon completion. disconnecting will move the QP to error state,
but it's not guaranteed that the wrs that _were_ posted will not
be executed. I'd say this is the opposite of ensuring...
