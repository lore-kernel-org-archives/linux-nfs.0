Return-Path: <SRS0=DjVz=QD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D200C282C0
	for <linux-nfs@archiver.kernel.org>; Sun, 27 Jan 2019 03:43:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C620A21903
	for <linux-nfs@archiver.kernel.org>; Sun, 27 Jan 2019 03:43:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GM/cQEze"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726511AbfA0DnK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 26 Jan 2019 22:43:10 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:53840 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726395AbfA0DnK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Jan 2019 22:43:10 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0R3ciZs194198;
        Sun, 27 Jan 2019 03:43:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=uMiyDvbAy6X3dZQSvKP/oFCtDF9SPBEoqrqAMqzn9Uo=;
 b=GM/cQEzedI2Jj/eA3UTb/AOifm7/juSh17ICRF7sdoHLNWdv/3DLYicTyOSn8QUhpwqr
 HftWaePz6eMB1iIQxAFr1KGQhkNLhIH7EASdsBagI0nY9XU656fM23cYIcrySBKaxc+4
 X1w5tAKbB5MiQlWVTqkooRQV9n18Zs6OI8MU313DRxfS/vOJqq2gugwGNcOS6KABsYN3
 d2FQQHFEw1BmSBzNYLYnllc5BS7IhNIvW0S6QSvZiwmLyq2drmqF8BljAEKIQaO6gPXG
 rkMgvypYDSnbclKZHTz+Vvr9/k225c25jSFE+UP4qG7smzT/EO6wRiyywZ5YUu/D/0ep 6g== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2q8g6qsygj-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 27 Jan 2019 03:43:05 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0R3h4wd028619
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 27 Jan 2019 03:43:04 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0R3h4CI018585;
        Sun, 27 Jan 2019 03:43:04 GMT
Received: from [192.168.1.184] (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sat, 26 Jan 2019 19:43:04 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v1] svcrdma: Remove max_sge check at connect time
From:   Chuck Lever <chuck.lever@oracle.com>
X-Mailer: iPad Mail (16C50)
In-Reply-To: <20190126224419.GC24528@fieldses.org>
Date:   Sat, 26 Jan 2019 22:43:02 -0500
Cc:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <20E2C34D-C219-47AD-9688-69201E4162A8@oracle.com>
References: <154845326910.67269.13122816140536911275.stgit@seurat.1015granger.net> <20190126224419.GC24528@fieldses.org>
To:     "J. Bruce Fields" <bfields@fieldses.org>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9148 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901270027
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> On Jan 26, 2019, at 5:44 PM, J. Bruce Fields <bfields@fieldses.org> wrote:=

>=20
>> On Fri, Jan 25, 2019 at 04:54:54PM -0500, Chuck Lever wrote:
>> Two and a half years ago, the client was changed to use gathered
>> Send for larger inline messages, in commit 655fec6987b ("xprtrdma:
>> Use gathered Send for large inline messages"). Several fixes were
>> required because there are a few in-kernel device drivers whose
>> max_sge is 3, and these were broken by the change.
>>=20
>> Apparently my memory is going, because some time later, I submitted
>> commit 25fd86eca11c ("svcrdma: Don't overrun the SGE array in
>> svc_rdma_send_ctxt"), and after that, commit f3c1fd0ee294 ("svcrdma:
>> Reduce max_send_sges"). These too incorrectly assumed in-kernel
>> device drivers would have more than a few Send SGEs available.
>>=20
>> The fix for the server side is not the same. This is because the
>> fundamental problem on the server is that, whether or not the client
>> has provisioned a chunk for the RPC reply, the server must squeeze
>> even the most complex RPC replies into a single RDMA Send. Failing
>> in the send path because of Send SGE exhaustion should never be an
>> option.
>>=20
>> Therefore, instead of failing when the send path runs out of SGEs,
>> switch to using a bounce buffer mechanism to handle RPC replies that
>> are too complex for the device to send directly. That allows us to
>> remove the max_sge check to enable drivers with small max_sge to
>> work again.
>>=20
>> Reported-by: Don Dutile <ddutile@redhat.com>
>> Fixes: 25fd86eca11c ("svcrdma: Don't overrun the SGE array in ...")
>=20
> Thanks!  Do you think this is suitable for 5.0 and stable, or should I
> save it up for 5.1?

Don would like to see it in 5.0 and stable.


> --b.
>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  105 +++++++++++++++++++++++++=
+++--
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |    9 +--
>> 2 files changed, 102 insertions(+), 12 deletions(-)
>>=20
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/=
svc_rdma_sendto.c
>> index 1aab305fbbb6..8235ca2159d1 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> @@ -531,6 +531,99 @@ void svc_rdma_sync_reply_hdr(struct svcxprt_rdma *rd=
ma,
>>                      DMA_TO_DEVICE);
>> }
>>=20
>> +/* If the xdr_buf has more elements than the device can
>> + * transmit in a single RDMA Send, then the reply will
>> + * have to be copied into a bounce buffer.
>> + */
>> +static bool svc_rdma_pull_up_needed(struct svcxprt_rdma *rdma,
>> +                    struct xdr_buf *xdr,
>> +                    __be32 *wr_lst)
>> +{
>> +    int elements;
>> +
>> +    /* xdr->head */
>> +    elements =3D 1;
>> +
>> +    /* xdr->pages */
>> +    if (!wr_lst) {
>> +        unsigned int remaining;
>> +        unsigned long pageoff;
>> +
>> +        pageoff =3D xdr->page_base & ~PAGE_MASK;
>> +        remaining =3D xdr->page_len;
>> +        while (remaining) {
>> +            ++elements;
>> +            remaining -=3D min_t(u32, PAGE_SIZE - pageoff,
>> +                       remaining);
>> +            pageoff =3D 0;
>> +        }
>> +    }
>> +
>> +    /* xdr->tail */
>> +    if (xdr->tail[0].iov_len)
>> +        ++elements;
>> +
>> +    /* assume 1 SGE is needed for the transport header */
>> +    return elements >=3D rdma->sc_max_send_sges;
>> +}
>> +
>> +/* The device is not capable of sending the reply directly.
>> + * Assemble the elements of @xdr into the transport header
>> + * buffer.
>> + */
>> +static int svc_rdma_pull_up_reply_msg(struct svcxprt_rdma *rdma,
>> +                      struct svc_rdma_send_ctxt *ctxt,
>> +                      struct xdr_buf *xdr, __be32 *wr_lst)
>> +{
>> +    unsigned char *dst, *tailbase;
>> +    unsigned int taillen;
>> +
>> +    dst =3D ctxt->sc_xprt_buf;
>> +    dst +=3D ctxt->sc_sges[0].length;
>> +
>> +    memcpy(dst, xdr->head[0].iov_base, xdr->head[0].iov_len);
>> +    dst +=3D xdr->head[0].iov_len;
>> +
>> +    tailbase =3D xdr->tail[0].iov_base;
>> +    taillen =3D xdr->tail[0].iov_len;
>> +    if (wr_lst) {
>> +        u32 xdrpad;
>> +
>> +        xdrpad =3D xdr_padsize(xdr->page_len);
>> +        if (taillen && xdrpad) {
>> +            tailbase +=3D xdrpad;
>> +            taillen -=3D xdrpad;
>> +        }
>> +    } else {
>> +        unsigned int len, remaining;
>> +        unsigned long pageoff;
>> +        struct page **ppages;
>> +
>> +        ppages =3D xdr->pages + (xdr->page_base >> PAGE_SHIFT);
>> +        pageoff =3D xdr->page_base & ~PAGE_MASK;
>> +        remaining =3D xdr->page_len;
>> +        while (remaining) {
>> +            len =3D min_t(u32, PAGE_SIZE - pageoff, remaining);
>> +
>> +            memcpy(dst, page_address(*ppages), len);
>> +            remaining -=3D len;
>> +            dst +=3D len;
>> +            pageoff =3D 0;
>> +        }
>> +    }
>> +
>> +    if (taillen)
>> +        memcpy(dst, tailbase, taillen);
>> +
>> +    ctxt->sc_sges[0].length +=3D xdr->len;
>> +    ib_dma_sync_single_for_device(rdma->sc_pd->device,
>> +                      ctxt->sc_sges[0].addr,
>> +                      ctxt->sc_sges[0].length,
>> +                      DMA_TO_DEVICE);
>> +
>> +    return 0;
>> +}
>> +
>> /* svc_rdma_map_reply_msg - Map the buffer holding RPC message
>>  * @rdma: controlling transport
>>  * @ctxt: send_ctxt for the Send WR
>> @@ -553,8 +646,10 @@ int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma=
,
>>    u32 xdr_pad;
>>    int ret;
>>=20
>> -    if (++ctxt->sc_cur_sge_no >=3D rdma->sc_max_send_sges)
>> -        return -EIO;
>> +    if (svc_rdma_pull_up_needed(rdma, xdr, wr_lst))
>> +        return svc_rdma_pull_up_reply_msg(rdma, ctxt, xdr, wr_lst);
>> +
>> +    ++ctxt->sc_cur_sge_no;
>>    ret =3D svc_rdma_dma_map_buf(rdma, ctxt,
>>                   xdr->head[0].iov_base,
>>                   xdr->head[0].iov_len);
>> @@ -585,8 +680,7 @@ int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,=

>>    while (remaining) {
>>        len =3D min_t(u32, PAGE_SIZE - page_off, remaining);
>>=20
>> -        if (++ctxt->sc_cur_sge_no >=3D rdma->sc_max_send_sges)
>> -            return -EIO;
>> +        ++ctxt->sc_cur_sge_no;
>>        ret =3D svc_rdma_dma_map_page(rdma, ctxt, *ppages++,
>>                        page_off, len);
>>        if (ret < 0)
>> @@ -600,8 +694,7 @@ int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,=

>>    len =3D xdr->tail[0].iov_len;
>> tail:
>>    if (len) {
>> -        if (++ctxt->sc_cur_sge_no >=3D rdma->sc_max_send_sges)
>> -            return -EIO;
>> +        ++ctxt->sc_cur_sge_no;
>>        ret =3D svc_rdma_dma_map_buf(rdma, ctxt, base, len);
>>        if (ret < 0)
>>            return ret;
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrd=
ma/svc_rdma_transport.c
>> index 6f9f4654338c..027a3b07d329 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -419,12 +419,9 @@ static struct svc_xprt *svc_rdma_accept(struct svc_x=
prt *xprt)
>>    /* Transport header, head iovec, tail iovec */
>>    newxprt->sc_max_send_sges =3D 3;
>>    /* Add one SGE per page list entry */
>> -    newxprt->sc_max_send_sges +=3D svcrdma_max_req_size / PAGE_SIZE;
>> -    if (newxprt->sc_max_send_sges > dev->attrs.max_send_sge) {
>> -        pr_err("svcrdma: too few Send SGEs available (%d needed)\n",
>> -               newxprt->sc_max_send_sges);
>> -        goto errout;
>> -    }
>> +    newxprt->sc_max_send_sges +=3D (svcrdma_max_req_size / PAGE_SIZE) + 1=
;
>> +    if (newxprt->sc_max_send_sges > dev->attrs.max_send_sge)
>> +        newxprt->sc_max_send_sges =3D dev->attrs.max_send_sge;
>>    newxprt->sc_max_req_size =3D svcrdma_max_req_size;
>>    newxprt->sc_max_requests =3D svcrdma_max_requests;
>>    newxprt->sc_max_bc_requests =3D svcrdma_max_bc_requests;

