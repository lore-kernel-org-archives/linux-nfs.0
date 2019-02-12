Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5339EC282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 14:35:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2AC9D214DA
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 14:35:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727750AbfBLOfZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 09:35:25 -0500
Received: from mx2.suse.de ([195.135.220.15]:41774 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729482AbfBLOfZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 09:35:25 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id E1380ACE3;
        Tue, 12 Feb 2019 14:35:23 +0000 (UTC)
Subject: Re: [PATCH v3] xprtrdma: Make sure Send CQ is allocated on an
 existing compvec
To:     Chuck Lever <chuck.lever@oracle.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <9d418664-1f67-c705-19a0-80fc9dc5a12b@suse.com>
 <91CC910C-48A1-4234-8347-39D1A710A87C@oracle.com>
From:   Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>
Message-ID: <f9291365-bbb7-f516-cac0-0a8b28fa22ec@suse.com>
Date:   Tue, 12 Feb 2019 15:35:21 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <91CC910C-48A1-4234-8347-39D1A710A87C@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 2/5/19 6:23 PM, Chuck Lever wrote:
>
>> On Feb 5, 2019, at 12:21 PM, Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com> wrote:
>>
>> Make sure the device has at least 2 completion vectors
>> before allocating to compvec#1
>>
>> Fixes: a4699f5647f3 (xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode)
>> Signed-off-by: Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>
> Anna, can you see that this fix gets into v5.0-rc ? Thanks!
>
>
Ping.

Haven't seen this upstream nor in the nfs repo (maybe I'm not checking the right one :) )
Any chance this gets picked up for 5.0 ?

Nicolas
