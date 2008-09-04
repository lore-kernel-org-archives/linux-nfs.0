From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: Re: XPRTRDMA max payload?
Date: Thu, 4 Sep 2008 12:00:10 -0400
Message-ID: <AB7BC5FB-EC6C-464C-9540-F609B27BF005@myri.com>
References: <B520CA74-F8C7-4D93-BC99-0B784F31C1D9@myri.com> <loom.20080904T152400-181@post.gmane.org>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Jim Schutt <jaschut@sandia.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1847 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752770AbYIDQAO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 12:00:14 -0400
In-Reply-To: <loom.20080904T152400-181-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 4, 2008, at 11:39 AM, Jim Schutt wrote:

> That's the only way I was able to find to do it.
>
> You'll want this patch also:
> http://marc.info/?l=linux-nfs&m=121936891515202&w=2
>
> There are some things on the stack dimensioned by
> RPCRDMA_MAX_DATA_SEGS.  I've not encountered any
> problems using 16 for RPCRDMA_MAX_DATA_SEGS,
> but I've not tried anything bigger.
>
> -- Jim

Hi Jim,

Thanks for the patch and the confirmation.

I would like to support 256 pages if possible, but I have other items  
that need fixing before worrying about performance. :-)

Scott


