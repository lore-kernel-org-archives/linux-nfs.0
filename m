Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77D0CC46475
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 17:11:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 42B6E20671
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 17:11:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42B6E20671
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728065AbeJXBfS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 21:35:18 -0400
Received: from mx1.redhat.com ([209.132.183.28]:39132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727730AbeJXBfS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Oct 2018 21:35:18 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3E350356F3;
        Tue, 23 Oct 2018 17:11:03 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-66-2.rdu2.redhat.com [10.10.66.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 7E6FF608F2;
        Tue, 23 Oct 2018 17:11:00 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@hammerspace.com>
Cc:     willy@infradead.org, sorenson@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] NFS: change sign of nfs_fh length
Date:   Tue, 23 Oct 2018 13:10:59 -0400
Message-ID: <6C36BA5A-94EC-4DEE-A435-5913D822CF92@redhat.com>
In-Reply-To: <c3ecb78f39487792cf01f868f2ee8521237b3a33.camel@hammerspace.com>
References: <85517ec3-e3d4-1bf3-8eea-cb274face1a7@redhat.com>
 <20181023154031.GF20085@bombadil.infradead.org>
 <c3ecb78f39487792cf01f868f2ee8521237b3a33.camel@hammerspace.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 23 Oct 2018 17:11:03 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 23 Oct 2018, at 12:09, Trond Myklebust wrote:

> On Tue, 2018-10-23 at 08:40 -0700, Matthew Wilcox wrote:
>> On Tue, Oct 23, 2018 at 10:34:57AM -0500, Frank Sorenson wrote:
>>>
>>> The filehandle has a length which is defined as a 32-bit
>>> "unsigned integer".  Change sign of the length appropriately.
>>>
>>> Signed-off-by: Frank Sorenson <sorenson@redhat.com>
>>
>> Is this a cleanup or does it fix a user-visible bug?
>
> It fixes the following comparison:
>
>                 if (len > NFS4_FHSIZE)
>                         return -EIO;
>
> but in practice, the next line should always catch the buffer overflow
> when len is negative:
>
>                 p = xdr_inline_decode(xdr, len);
>                 if (unlikely(!p))
>                         goto out_overflow;

Maybe I am missing something, but if we're depending on:

static __be32 * __xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes)
{
    unsigned int nwords = XDR_QUADLEN(nbytes);
    __be32 *p = xdr->p;
    __be32 *q = p + nwords;

    if (unlikely(nwords > xdr->nwords || q > xdr->end || q < p))
        return NULL;

and nbytes is 0xffffffff, then nwords ends up being 0.. so this if statement
could easily miss it.

Ben
