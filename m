Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 620B3C169C4
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 11:12:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3C6B52075D
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 11:12:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729760AbfBFLMJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 06:12:09 -0500
Received: from mx1.redhat.com ([209.132.183.28]:45240 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729757AbfBFLMI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Feb 2019 06:12:08 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8CFD1C065F63;
        Wed,  6 Feb 2019 11:12:08 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 9EA4C18B84;
        Wed,  6 Feb 2019 11:12:07 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@hammerspace.com>
Cc:     anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Don't use page_file_mapping after removing the page
Date:   Wed, 06 Feb 2019 06:12:06 -0500
Message-ID: <3EF9B995-18CA-4DAA-AA85-47A42A1D52B5@redhat.com>
In-Reply-To: <B7217157-4540-43E9-A355-C38A0EEC1FAA@redhat.com>
References: <b85247642d77ea12153d042a4dce85b94d7624ca.1549303962.git.bcodding@redhat.com>
 <c525031691d77cff46adc30dc16bf1d19fb46900.camel@hammerspace.com>
 <22D43CDC-BB14-4C8F-A10E-DF7816EBF0B0@redhat.com>
 <C1BFD544-69A6-4AE4-87EA-2C711C6ABB3B@redhat.com>
 <9857F7D4-FA2E-43D0-8D4B-4C753A81687C@redhat.com>
 <628931F4-B625-4430-96FF-268CF926934A@redhat.com>
 <602aa0cc867676254cf09d6e329eb6a8f7345920.camel@hammerspace.com>
 <B7217157-4540-43E9-A355-C38A0EEC1FAA@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 06 Feb 2019 11:12:08 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 5 Feb 2019, at 5:23, Benjamin Coddington wrote:

> On 4 Feb 2019, at 16:40, Trond Myklebust wrote:
>> What about the case when the page is in the swap cache? Is that also
>> safe?
>
> I think the case you'd like me to consider is when a file on NFS has its
> mapping backed by pages that are in swap.  In that case, it makes no sense
> to check the count of pages in the swap file's mapping to determine whether
> to set NFS_INO_INVALID_DATA.  We actually want to optimize away the
> revalidation if the NFS file lacks mapped pages.

All this makes me nervous about breaking swap, and is probably not
appropriate for a fix here so I am going to drop this approach.

Ben
