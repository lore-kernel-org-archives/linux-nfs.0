Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A17FCC10F0A
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:06:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7B3E420811
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:06:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726669AbfC1UGG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:06:06 -0400
Received: from mx1.redhat.com ([209.132.183.28]:57354 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726660AbfC1UGG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Mar 2019 16:06:06 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F0A73307EA9F;
        Thu, 28 Mar 2019 20:06:05 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-117-220.phx2.redhat.com [10.3.117.220])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 83A8361090;
        Thu, 28 Mar 2019 20:06:05 +0000 (UTC)
Subject: Re: [PATCH] nfsiostat: replace 'list' reserved word
To:     Matthew Ruffell <matthew.ruffell@canonical.com>,
        linux-nfs@vger.kernel.org
References: <20190324213318.18296-1-matthew.ruffell@canonical.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <d5103bda-5c81-5e7c-afe6-1b9e18c60d8b@RedHat.com>
Date:   Thu, 28 Mar 2019 16:06:05 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190324213318.18296-1-matthew.ruffell@canonical.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 28 Mar 2019 20:06:06 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 3/24/19 5:33 PM, Matthew Ruffell wrote:
> list is a reserved word in python and should not be used as a variable
> name. Changing list to devicelist for list_nfs_mounts()
> 
> Fixes: https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/1821261
> 
> Signed-off-by: Matthew Ruffell <matthew.ruffell@canonical.com>
Committed...

steved.
> ---
>  tools/nfs-iostat/nfs-iostat.py | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
> index 7cbe543..dec0e86 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -493,20 +493,20 @@ def list_nfs_mounts(givenlist, mountstats):
>         return a full list if the given list is empty -
>         may return an empty list if none found
>      """
> -    list = []
> +    devicelist = []
>      if len(givenlist) > 0:
>          for device in givenlist:
>              stats = DeviceData()
>              stats.parse_stats(mountstats[device])
>              if stats.is_nfs_mountpoint():
> -                list += [device]
> +                devicelist += [device]
>      else:
>          for device, descr in mountstats.items():
>              stats = DeviceData()
>              stats.parse_stats(descr)
>              if stats.is_nfs_mountpoint():
> -                list += [device]
> -    return list
> +                devicelist += [device]
> +    return devicelist
>  
>  def iostat_command(name):
>      """iostat-like command for NFS mount points
> 
