Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8D17C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:07:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 954A8217D9
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:07:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726605AbfBSQHw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 11:07:52 -0500
Received: from mx1.redhat.com ([209.132.183.28]:36666 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726321AbfBSQHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 11:07:52 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 85AEAC007330;
        Tue, 19 Feb 2019 16:07:52 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 17B6360140;
        Tue, 19 Feb 2019 16:07:52 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: fix addrinfo usage with musl-1.1.21
To:     Peter Wagner <tripolar@gmx.at>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20190217173901.33296254@onion.lan>
 <1081BBCD-8CA0-49CC-A02C-16F46FF613BF@oracle.com>
 <20190218001153.3d21b28c@onion.lan>
 <34D9E70A-7F29-4C6B-8A10-18F7A7EFFE2E@oracle.com>
 <137b8db8-a6d6-33a6-408b-73f8915eee08@RedHat.com>
 <EE3790BC-A5B4-4C34-9F21-7009579B3A25@oracle.com>
 <530ec927-e9c6-490c-1382-8e5be1aea203@RedHat.com>
 <0B1E18B0-0034-4612-B63B-41155D2E0D64@oracle.com>
 <20190218222600.198f25d1@onion.lan> <20190219100330.7679f4a3@onion.lan>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <4df6f5e7-527f-4dae-02e5-11ca9ad67adf@RedHat.com>
Date:   Tue, 19 Feb 2019 11:07:51 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190219100330.7679f4a3@onion.lan>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 19 Feb 2019 16:07:52 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hey Peter,

On 2/19/19 4:03 AM, Peter Wagner wrote:
> i updated to code to the latest version

Would you please create a new thread with 
each patch version adding the version to
the subject line ex [PATCH V2].

It just make it much easier for me to
find the patch... tia,

steved.
