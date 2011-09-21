Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:60820 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab1IUKi2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 06:38:28 -0400
Message-ID: <4E79BE96.1070905@panasas.com>
Date: Wed, 21 Sep 2011 13:38:14 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: <tao.peng@emc.com>
CC: <bhalevy@tonian.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>, <honey@citi.umich.edu>, <rees@umich.edu>
Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
References: <1316488728-24912-1-git-send-email-rees@umich.edu> <1316488728-24912-3-git-send-email-rees@umich.edu> <1316558461.15093.4.camel@lade.trondhjem.org> <20110921002917.GA30770@merit.edu> <F19688880B763E40B28B2B462677FBF805C4952916@MX09A.corp.emc.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480226@SACMVEXC2-PRD.hq.netapp.com> <F19688880B763E40B28B2B462677FBF805C495295A@MX09A.corp.emc.com> <4E798C93.40409@tonian.com> <F19688880B763E40B28B2B462677FBF805C4952A24@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805C4952A24@MX09A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/21/2011 01:23 PM, tao.peng@emc.com wrote:
> 
> Unless we do following:
> 1. preallocate memory for extent state convertion
> 2. use nfsiod/rpciod to handle bl_write_cleanup
> 3. for pnfs error case, create a kthread to recollapse and resend to MDS
> 
> not sure if it worth the complexity though...
> 
> Cheers,
> Tao
> 

Please forgive my ignorance but what is the big difference between
a kthread and a workqueue? I thought a workqueue is just a kthread
and some memory structures (list).

I agree with "keep things simple"

But what do I know ;-)

Thanks
Boaz
