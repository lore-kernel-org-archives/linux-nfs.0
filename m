From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 02/10] svcrdma: Add FRMR get/put services
Date: Thu, 25 Sep 2008 15:31:26 -0500
Message-ID: <48DBF51E.3080700@opengridcomputing.com>
References: <1221564879-85046-1-git-send-email-tom@opengridcomputing.com> <1221564879-85046-2-git-send-email-tom@opengridcomputing.com> <1221564879-85046-3-git-send-email-tom@opengridcomputing.com> <20080924194538.GM5772@fieldses.org> <48DB9F5A.4090401@opengridcomputing.com> <20080925144439.GA29498@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:36169 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754746AbYIYUb1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2008 16:31:27 -0400
In-Reply-To: <20080925144439.GA29498@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Sep 25, 2008 at 09:25:30AM -0500, Tom Tucker wrote:
>> J. Bruce Fields wrote:
>>> On Tue, Sep 16, 2008 at 06:34:31AM -0500, Tom Tucker wrote:
>>>> +	}
>>>> +	frmr->map_len = 0;
>>>> +	frmr->page_list_len = 0;
>>>> +
>>>> +	return frmr;
>>>> +}
>>>> +
>>>> +static void frmr_unmap_dma(struct svcxprt_rdma *xprt,
>>>> +			   struct svc_rdma_fastreg_mr *frmr)
>>>> +{
>>>> +	int page_no;
>>>> +	dprintk("svcrdma:%s: xprt %p page_list_len %d\n",
>>>> +		__func__, xprt, frmr->page_list_len);
>>>> +	for (page_no = 0; page_no < frmr->page_list_len; page_no++) {
>>>> +		dma_addr_t addr = frmr->page_list->page_list[page_no];
>>>> +		dprintk("svcrdma:      %08x %llx\n", frmr->mr->lkey, addr);
>>> Are these dprintk's going to be useful for debugging user issues
>>> remotely, or were they just for your personal use while writing the
>>> code?
>>>
>>> We saw recently that we may already have too many dprintk's for them to
>>> be useful in production, and the above seem likely to be rather
>>> frequent.
>> Agreed. It needs to go.
> 
> OK!  That being the case: I ignored other additions of dprintk's in this
> patch set; would you mind scanning through them to see if there's others
> that should also go?  Stuff to look for, off the top of my head:
> 
> 	- How frequently is a dprintk going to be called?
> 	- Is this dprintk redundant with some other dprintk?  (E.g. are
> 	  a function and its caller both dprintk'ing the same
> 	  information?)
> 	- Is this going to be help debug problems with users in the
> 	  field?
> 

Yes, I will remove all pointless chatter :-)

> --b.

