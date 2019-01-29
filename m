Return-Path: <SRS0=GD9Z=QF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C39FC169C4
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 22:35:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4DBE12054F
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 22:35:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727342AbfA2WfC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Jan 2019 17:35:02 -0500
Received: from mx1.redhat.com ([209.132.183.28]:54710 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727332AbfA2WfC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Jan 2019 17:35:02 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 37EBE7AE8B;
        Tue, 29 Jan 2019 22:35:02 +0000 (UTC)
Received: from [10.10.125.230] (ovpn-125-230.rdu2.redhat.com [10.10.125.230])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 1765719C65;
        Tue, 29 Jan 2019 22:35:00 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@hammerspace.com>
Cc:     anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Always return the error that truncates a flushing
 page
Date:   Tue, 29 Jan 2019 22:34:57 +0000
Message-ID: <3B6A83BD-9BCB-41CD-9624-AB1158A5CB24@redhat.com>
In-Reply-To: <e87423e25a6aeff640199eb1a776194cfef8a041.camel@hammerspace.com>
References: <1cbf359e173a9f93e7c858faa43e623dda3858df.1548602308.git.bcodding@redhat.com>
 <9fc3d4ee7d8eafdfdb7b7c1397ecb25dd22e12b7.camel@hammerspace.com>
 <4512E750-0B6F-4842-B7B8-469FF04FBB00@redhat.com>
 <e87423e25a6aeff640199eb1a776194cfef8a041.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 29 Jan 2019 22:35:02 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 29 Jan 2019, at 20:49, Trond Myklebust wrote:

> On Mon, 2019-01-28 at 13:55 -0500, Benjamin Coddington wrote:
>> On 28 Jan 2019, at 12:59, Trond Myklebust wrote:
>>> Hi Ben
>>>
>>> We were apparently both looking at the same code last week ☺. I
>>> have a
>>> similar patch, but that also fixes a similar clobbering issue with
>>> the
>>> nfs_error_is_fatal() error just a few lines further down.
>>>
>>> Without the extra hunk, we could end up converting an interrupted
>>> call
>>> into a 'successful' write.
>>>
>>> Cheers
>>>   Trond
>>
>> Looks right to me.  I hope you'll take the Fixes and stable version
>> from
>> my patch, which will cover the problem I'm seeing.
>>
>> Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
>>
>
> At first, I thought I'd have to split this patch in 2 so that it could
> apply to 4.11 and 4.12, but it looks to me as if the commit from the
> Fixes line you were showing is actually only present in 4.12 and 
> later.
> Am I wrong?

You're right.  I did

# git describe c373fff7bd25
v4.11-rc7-70-gc373fff7bd25

.. and assumed it ended up in v4.11.  I wonder what actually happened to 
it, I'll see if I can find out.

Ben
