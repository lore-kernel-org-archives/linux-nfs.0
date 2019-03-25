Return-Path: <SRS0=29O7=R4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4CADC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 23:23:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 968392080F
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 23:23:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726616AbfCYXXQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Mar 2019 19:23:16 -0400
Received: from fieldses.org ([173.255.197.46]:56088 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726350AbfCYXXQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Mar 2019 19:23:16 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 343A31C81; Mon, 25 Mar 2019 19:23:16 -0400 (EDT)
Date:   Mon, 25 Mar 2019 19:23:16 -0400
To:     Matthew Ruffell <matthew.ruffell@canonical.com>
Cc:     linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] nfsiostat: replace 'list' reserved word
Message-ID: <20190325232316.GC23190@fieldses.org>
References: <20190324213318.18296-1-matthew.ruffell@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190324213318.18296-1-matthew.ruffell@canonical.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Adding steved to cc.--b.

On Mon, Mar 25, 2019 at 10:33:18AM +1300, Matthew Ruffell wrote:
> list is a reserved word in python and should not be used as a variable
> name. Changing list to devicelist for list_nfs_mounts()
> 
> Fixes: https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/1821261
> 
> Signed-off-by: Matthew Ruffell <matthew.ruffell@canonical.com>
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
> -- 
> 2.19.1
