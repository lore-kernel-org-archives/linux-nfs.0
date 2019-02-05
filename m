Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48782C282CB
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 12:10:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1EBAD2080F
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 12:10:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726696AbfBEMKg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 07:10:36 -0500
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:40384 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725934AbfBEMKg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 07:10:36 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B7AA580D;
        Tue,  5 Feb 2019 04:10:35 -0800 (PST)
Received: from [10.1.197.50] (e120937-lin.cambridge.arm.com [10.1.197.50])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1CB143F675;
        Tue,  5 Feb 2019 04:10:34 -0800 (PST)
Subject: Re: [aarch64] refcount_t: use-after-free in NFS with 64k pages
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     Punit Agrawal <punit.agrawal@arm.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <c8b0e53b-eccf-5914-af8d-ee47dccd3bcd@arm.com>
 <87va5yvubk.fsf@e105922-lin.cambridge.arm.com>
 <abf58cfc-a575-cb36-47a1-b1135f080362@arm.com>
 <65CE8FC5-3ADB-4E61-8127-70B979B037A0@redhat.com>
From:   Cristian Marussi <cristian.marussi@arm.com>
Message-ID: <e99fd27b-9e60-22fc-af6b-da93b0e0ca0f@arm.com>
Date:   Tue, 5 Feb 2019 12:10:33 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <65CE8FC5-3ADB-4E61-8127-70B979B037A0@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Ben

On 05/02/2019 11:53, Benjamin Coddington wrote:
> Hello Cristian and Punit,
> 
> Did you ever get to the bottom of this one?  We just saw this on one run 
> of our 4.18.0-era ppc64le, and I'm wondering if we ever found the root 
> cause.

unfortunately I stopped working actively on finding the root cause, since I've
found a viable workaround that let us unblock our broken LTP runs.

Setting wsize=65536 in NFS bootparams completely solves the issue with 64k pages
(and does NOT break 4k either :D): this confirmed my hyp that there is some sort
of race when accounting refcounts during the lifetime of nfs_page structs which
leads to a misscounted refcount...but as I said I never looked back into that
again (but never say never...)

Hope this helps...

Regards

Cristian

> 
> Ben
> 

