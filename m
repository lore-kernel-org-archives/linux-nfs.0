Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E12FC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 18:00:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E2EBA2075C
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 18:00:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726977AbfCKSAk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 14:00:40 -0400
Received: from mx1.redhat.com ([209.132.183.28]:57878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726864AbfCKSAj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Mar 2019 14:00:39 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D3C4166986;
        Mon, 11 Mar 2019 18:00:39 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-116-95.phx2.redhat.com [10.3.116.95])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 89E6B60C4E;
        Mon, 11 Mar 2019 18:00:39 +0000 (UTC)
Subject: Re: Patch: Provide the offending UID/GID/name for which mapping fails
 we can debug the reasons
To:     Richard Sharpe <realrichardsharpe@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <CACyXjPwSWO53oFhGDowUSzO0qVPjq3JNWdGDN2BO5guBMX+dyQ@mail.gmail.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <2943e6d0-c5ed-69ea-d463-946c7ba23101@RedHat.com>
Date:   Mon, 11 Mar 2019 14:00:39 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CACyXjPwSWO53oFhGDowUSzO0qVPjq3JNWdGDN2BO5guBMX+dyQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 11 Mar 2019 18:00:39 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 3/6/19 7:46 PM, Richard Sharpe wrote:
> Hi folks,
> 
> It is annoying to see these messages in /var/log/messages:
> 
> 2019-03-04 23:15:23 nfsidmap[25468]: name_lookup: nfs4_gid_to_name:
> failed: Unknown error -2
> 
> because you have no idea what UID/GID/name failed.
> 
> Attached is a git-format-patch patch to add the additional info to
> those error messages.
> 
> It does not add any new messages.
> 
> Let me know what you think.
> 
Committed... 

Please, next time inline the patch.

steved.
