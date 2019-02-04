Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16536C282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 20:31:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D831D2073D
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 20:31:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728031AbfBDUbL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 15:31:11 -0500
Received: from mx1.redhat.com ([209.132.183.28]:57662 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728683AbfBDUbL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Feb 2019 15:31:11 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D002AA404B;
        Mon,  4 Feb 2019 20:31:10 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id D5227101F97A;
        Mon,  4 Feb 2019 20:31:09 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@hammerspace.com>
Cc:     anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Don't use page_file_mapping after removing the page
Date:   Mon, 04 Feb 2019 15:31:07 -0500
Message-ID: <628931F4-B625-4430-96FF-268CF926934A@redhat.com>
In-Reply-To: <9857F7D4-FA2E-43D0-8D4B-4C753A81687C@redhat.com>
References: <b85247642d77ea12153d042a4dce85b94d7624ca.1549303962.git.bcodding@redhat.com>
 <c525031691d77cff46adc30dc16bf1d19fb46900.camel@hammerspace.com>
 <22D43CDC-BB14-4C8F-A10E-DF7816EBF0B0@redhat.com>
 <C1BFD544-69A6-4AE4-87EA-2C711C6ABB3B@redhat.com>
 <9857F7D4-FA2E-43D0-8D4B-4C753A81687C@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 04 Feb 2019 20:31:10 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


On 4 Feb 2019, at 14:20, Benjamin Coddington wrote:

> On 4 Feb 2019, at 14:07, Benjamin Coddington wrote:
>
>> On 4 Feb 2019, at 14:03, Benjamin Coddington wrote:
>>
>>> On 4 Feb 2019, at 13:32, Trond Myklebust wrote:
>>>
>>>> On Mon, 2019-02-04 at 13:13 -0500, Benjamin Coddington wrote:
>>>>> If nfs_page_async_flush() removes the page from the mapping, then we
>>>>> can't use page_file_mapping() on it as nfs_updatepate() is wont to do
>>>>> when receiving an error.  Instead, simplify nfs_zap_mapping() to take
>>>>> the inode.
>>>>>
>>>>
>>>> Won't this break NFS swap?
>>>
>>> I guess it may, but then I wonder: is that a thing that anyone does?  It
>>> sounds like a terrible idea..
>>>
>>> I'm curious enough though, and doing some research on it.
>>
>> There's enough to commits in the tree fixing problem or supporting swap
>> on NFS, so I suppose I've just missed all that.
>
> So for diskless systems, ah.  It makes sense.
>
> But does it make any sense to set NFS_INO_INVALID_DATA on a swap file?
> Does anyone share them?
>
> Dazed and confused, but trying to continue..

So if the page is backing a swap file, nfs_zap_mapping() will fail to set
NFS_INO_INVALID_DATA because i_mapping.nrpages will always be 0.

But it looks like NFS has already decided to not care if the mapping needs
revalidation for swap, since we assume /shared/ swap files are insane.

So without testing swap on NFS at all, it seems safe.

This is all new to me, though, so I need experienced revalidation of this
reasoning myself.

Perhaps it needs a comment to explain why it is safe to do..  any thoughts?

Ben
