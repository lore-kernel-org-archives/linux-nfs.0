Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FB74C282CC
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 12:14:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ECF5A2175B
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 12:14:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728825AbfBEMOW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 07:14:22 -0500
Received: from mx1.redhat.com ([209.132.183.28]:40516 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726065AbfBEMOV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 07:14:21 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 10140C01DE1D;
        Tue,  5 Feb 2019 12:14:21 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 0C5921001914;
        Tue,  5 Feb 2019 12:14:19 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Cristian Marussi" <cristian.marussi@arm.com>
Cc:     "Punit Agrawal" <punit.agrawal@arm.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [aarch64] refcount_t: use-after-free in NFS with 64k pages
Date:   Tue, 05 Feb 2019 07:14:18 -0500
Message-ID: <9C25D1F9-3A25-4CF3-822E-CE25829642D9@redhat.com>
In-Reply-To: <e99fd27b-9e60-22fc-af6b-da93b0e0ca0f@arm.com>
References: <c8b0e53b-eccf-5914-af8d-ee47dccd3bcd@arm.com>
 <87va5yvubk.fsf@e105922-lin.cambridge.arm.com>
 <abf58cfc-a575-cb36-47a1-b1135f080362@arm.com>
 <65CE8FC5-3ADB-4E61-8127-70B979B037A0@redhat.com>
 <e99fd27b-9e60-22fc-af6b-da93b0e0ca0f@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 05 Feb 2019 12:14:21 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 5 Feb 2019, at 7:10, Cristian Marussi wrote:

> Hi Ben
>
> On 05/02/2019 11:53, Benjamin Coddington wrote:
>> Hello Cristian and Punit,
>>
>> Did you ever get to the bottom of this one?  We just saw this on one 
>> run
>> of our 4.18.0-era ppc64le, and I'm wondering if we ever found the 
>> root
>> cause.
>
> unfortunately I stopped working actively on finding the root cause, 
> since I've
> found a viable workaround that let us unblock our broken LTP runs.
>
> Setting wsize=65536 in NFS bootparams completely solves the issue with 
> 64k pages
> (and does NOT break 4k either :D): this confirmed my hyp that there is 
> some sort
> of race when accounting refcounts during the lifetime of nfs_page 
> structs which
> leads to a misscounted refcount...but as I said I never looked back 
> into that
> again (but never say never...)
>
> Hope this helps...

Hmm, interesting..

Will you share your reproducer with me?  That will save me some time.

Ben
