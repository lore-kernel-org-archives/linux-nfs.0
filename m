Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:33508 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab1IULnB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 07:43:01 -0400
Message-ID: <4E79CD8F.6050901@panasas.com>
Date: Wed, 21 Sep 2011 14:42:07 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>
CC: <tao.peng@emc.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>, <honey@citi.umich.edu>, <rees@umich.edu>
Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
References: <1316488728-24912-1-git-send-email-rees@umich.edu> <1316488728-24912-3-git-send-email-rees@umich.edu> <1316558461.15093.4.camel@lade.trondhjem.org> <20110921002917.GA30770@merit.edu> <F19688880B763E40B28B2B462677FBF805C4952916@MX09A.corp.emc.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480226@SACMVEXC2-PRD.hq.netapp.com> <F19688880B763E40B28B2B462677FBF805C495295A@MX09A.corp.emc.com> <4E798C93.40409@tonian.com> <F19688880B763E40B28B2B462677FBF805C4952A24@MX09A.corp.emc.com> <4E79C2F0.30303@tonian.com> <F19688880B763E40B28B2B462677FBF805C4952A34@MX09A.corp.emc.com> <4E79CA34.3060602@tonian.com>
In-Reply-To: <4E79CA34.3060602@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/21/2011 02:27 PM, Benny Halevy wrote:
>> Unless we do following:
>> 1. preallocate memory for extent state convertion
>> 2. use nfsiod/rpciod to handle bl_write_cleanup
>> 3. for pnfs error case, create a kthread to recollapse and resend to MDS
>> I don't quite understand. How do you use nfs state manager to do other tasks?
> 
> You need to keep a list of things to do hanging off of the nfs client structure
> and set a bit in cl_state telling the state manager it has work to do
> and wake it up.  It then needs to go over the list of, say nfs_inodes
> and call into the layout driver to handle the errors.
> 
> Benny

Good god, Is it not already too complicated?

The LD is out of the picture. You all seemed to agree that
the LD has reported an io_done on the nfsiod/rpciod, and in the error case
Generic layer needs to do it's coalescing on some other thread. So
your description above is not correct, the LD is out of the picture.

It all looks too complicated for me. A pnfs workqueue for both 2 and 3
above is very good. Specially since the workqueue also shares global
pool threads, No? I like it that there is a preallocated thread for
the error-case, think about it.

Thanks
Boaz
