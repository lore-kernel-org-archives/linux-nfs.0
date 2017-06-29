Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48169 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751532AbdF2Uor (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jun 2017 16:44:47 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 09/18] sunrpc: Allocate one more page per svc_rqst
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170629202004.GC4178@fieldses.org>
Date: Thu, 29 Jun 2017 16:44:43 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <EB8E2100-6176-424A-B687-FE84758889E0@oracle.com>
References: <20170623211150.5162.59075.stgit@klimt.1015granger.net> <20170623211816.5162.54447.stgit@klimt.1015granger.net> <20170629202004.GC4178@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the review!

> On Jun 29, 2017, at 4:20 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> I'm confused by this one:
> 
> On Fri, Jun 23, 2017 at 05:18:16PM -0400, Chuck Lever wrote:
>> svcrdma needs 259 pages for 1MB NFSv4.0 READ requests:
>> 
>> - 1 page for the transport header and head iovec
>> - 256 pages for the data payload
>> - 1 page for the trailing GETATTR request (since NFSD XDR decoding
>>   does not look for a tail iovec, the GETATTR is stuck at the end
>>   of the rqstp->rq_arg.pages list)
>> - 1 page for building the reply xdr_buf
>> 
>> Note that RPCSVC_MAXPAGES is defined as:
>> 
>> 	((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 2 + 1)
>> 
>> I don't understand why the "+PAGE_SIZE-1" is in there, because
>> division will always round the result down to
>> 
>> 	(RPCSVC_MAXPAYLOAD / PAGE_SIZE + 2 + 1)
> 
> I think you're assuming that RPCSVC_MAXPAYLOAD is a multiple of
> PAGE_SIZE.  Maybe that's true in all cases (I haven't checked), but it
> seems harmless to handle the case where it's not.

include/linux/sunrpc/svc.h says:

126  * Maximum payload size supported by a kernel RPC server.
127  * This is use to determine the max number of pages nfsd is
128  * willing to return in a single READ operation.
129  *
130  * These happen to all be powers of 2, which is not strictly
131  * necessary but helps enforce the real limitation, which is
132  * that they should be multiples of PAGE_SIZE.

Note that the same calculation in svc_alloc_args() assumes
that serv->sv_max_mesg is a multiple of PAGE_SIZE:

	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;

It's confusing that the value of RPCSVC_MAXPAGES is not computed
the same way as "pages" is.


>> Let's remove the "-1" to get 260 pages maximum.
> 
> Why?  (I'm not necessarily opposed, I just missed the explanation.)

The top of the patch description explains why I need 259 pages.

MAX_PAGES has to be 260 in order for this check in svc_alloc_args()

	if (pages >= RPCSVC_MAXPAGES) {
		/* use as many pages as possible */
		pages = RPCSVC_MAXPAGES - 1;

to allow 260 elements of the array to be filled in.


> --b.
> 
>> Then svc_alloc_args() needs to ask for pages according to this
>> same formula, otherwise it will never allocate enough.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/svc.h |    3 +--
>> net/sunrpc/svc_xprt.c      |    8 +++++---
>> 2 files changed, 6 insertions(+), 5 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> index 11cef5a..35c274f 100644
>> --- a/include/linux/sunrpc/svc.h
>> +++ b/include/linux/sunrpc/svc.h
>> @@ -176,8 +176,7 @@ static inline void svc_get(struct svc_serv *serv)
>>  * We using ->sendfile to return read data, we might need one extra page
>>  * if the request is not page-aligned.  So add another '1'.
>>  */
>> -#define RPCSVC_MAXPAGES		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE \
>> -				+ 2 + 1)
>> +#define RPCSVC_MAXPAGES	((RPCSVC_MAXPAYLOAD + PAGE_SIZE) / PAGE_SIZE + 2 + 1)
>> 
>> static inline u32 svc_getnl(struct kvec *iov)
>> {
>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>> index 7bfe1fb..9bd484d 100644
>> --- a/net/sunrpc/svc_xprt.c
>> +++ b/net/sunrpc/svc_xprt.c
>> @@ -659,11 +659,13 @@ static int svc_alloc_arg(struct svc_rqst *rqstp)
>> 	int i;
>> 
>> 	/* now allocate needed pages.  If we get a failure, sleep briefly */
>> -	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
>> -	WARN_ON_ONCE(pages >= RPCSVC_MAXPAGES);
>> -	if (pages >= RPCSVC_MAXPAGES)
>> +	pages = (serv->sv_max_mesg + (2 * PAGE_SIZE)) >> PAGE_SHIFT;
>> +	if (pages >= RPCSVC_MAXPAGES) {
>> +		pr_warn_once("svc: warning: pages=%u >= RPCSVC_MAXPAGES=%lu\n",
>> +			     pages, RPCSVC_MAXPAGES);
>> 		/* use as many pages as possible */
>> 		pages = RPCSVC_MAXPAGES - 1;
>> +	}
>> 	for (i = 0; i < pages ; i++)
>> 		while (rqstp->rq_pages[i] == NULL) {
>> 			struct page *p = alloc_page(GFP_KERNEL);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



