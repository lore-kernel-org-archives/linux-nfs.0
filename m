Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35240 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbbGTRUB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 13:20:01 -0400
Received: by wibxm9 with SMTP id xm9so97816389wib.0
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2015 10:19:59 -0700 (PDT)
Subject: Re: [PATCH RFC] svcrdma: Fix possible over population
 fast_reg_page_list
To: Chuck Lever <chuck.lever@oracle.com>, Sagi Grimberg <sagig@mellanox.com>
References: <1437411614-29722-1-git-send-email-sagig@mellanox.com>
 <C3FCF5F9-07D6-4A6D-8114-CB700038797E@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Steve Wise <swise@opengridcomputing.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55AD2DBE.7090006@dev.mellanox.co.il>
Date: Mon, 20 Jul 2015 20:19:58 +0300
MIME-Version: 1.0
In-Reply-To: <C3FCF5F9-07D6-4A6D-8114-CB700038797E@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/20/2015 8:13 PM, Chuck Lever wrote:
>
> On Jul 20, 2015, at 1:00 PM, Sagi Grimberg <sagig@mellanox.com> wrote:
>
>> When accounting the needed_pages, we need to look into
>> the page_list->max_page_list_len and not the global
>> context xprt->sc_frmr_pg_list_len.
>>
>> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
>> ---
>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    3 ++-
>> 1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> index 2e1348b..b19ffd3 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> @@ -244,7 +244,8 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
>>
>> 	ctxt->direction = DMA_FROM_DEVICE;
>> 	ctxt->frmr = frmr;
>> -	pages_needed = min_t(int, pages_needed, xprt->sc_frmr_pg_list_len);
>> +	pages_needed = min_t(int, pages_needed,
>> +			     frmr->page_list->max_page_list_len);
>
> This is the last user of sc_frmr_pg_list_len. If Steve thinks this is
> a good change, then why not remove it.
>
> The client uses ib_device_attr::max_fast_reg_page_list_len too.
> Should it be fixed?

I've actually been playing around with this as part of the porting
to the new fast registration API which makes fast_reg_page_list go away.
xprtrdma and svcrdma are switched to use scatterlists instead and
the drivers handle the page lists internally.

So we can remove it, but I think this whole section will go away
eventually.
