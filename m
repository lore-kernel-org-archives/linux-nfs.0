Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-18.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,NICE_REPLY_A,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5609C433DB
	for <linux-nfs@archiver.kernel.org>; Sat, 26 Dec 2020 19:33:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 877692068D
	for <linux-nfs@archiver.kernel.org>; Sat, 26 Dec 2020 19:33:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725955AbgLZTdi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 26 Dec 2020 14:33:38 -0500
Received: from us-smtp-delivery-124.mimecast.com ([63.128.21.124]:52879 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725927AbgLZTdi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2020 14:33:38 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1609011131;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=e39OepsB0eRymmj6cqFt4gmBOQFlYgnvBpGIUE4hT5o=;
        b=P3yqYlzBG2vfrrm+qTd1IULKbeWT8K83BiFuuEplKl3+KbAQvivhBXKEf2fnz/gaMtQso4
        NDdOItCqBKPO6bXzWAWzee6Xq20jr8yPTgu3b6LMyLA1yq5z42YD153fqJaP57VUMUC+QR
        b3hMI+F94UM7WLGLZLBM2HNm6ldI4F0=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-564-0dxJ_DhcNwq4KROtv4-56w-1; Sat, 26 Dec 2020 14:32:09 -0500
X-MC-Unique: 0dxJ_DhcNwq4KROtv4-56w-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 9916E800D55;
        Sat, 26 Dec 2020 19:32:08 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-112-77.phx2.redhat.com [10.3.112.77])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B3806189B8;
        Sat, 26 Dec 2020 19:32:07 +0000 (UTC)
Subject: Re: [PATCH 2/2] mountd: never root squash on the pseudofs
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        "J. Bruce Fields" <bfields@redhat.com>
References: <20201203010546.GB348347@pick.fieldses.org>
 <1606958097-9041-1-git-send-email-bfields@fieldses.org>
 <1606958097-9041-2-git-send-email-bfields@fieldses.org>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <c8356607-57b7-ef02-be19-6eeb76789731@RedHat.com>
Date:   Sat, 26 Dec 2020 14:32:56 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.6.0
MIME-Version: 1.0
In-Reply-To: <1606958097-9041-2-git-send-email-bfields@fieldses.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 12/2/20 8:14 PM, bfields@fieldses.org wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> As with security flavors and "secure" ports, we tried to code this so
> that pseudofs directories would inherit root squashing from their
> children, but it doesn't really work as coded and I'm not sure it's
> useful.
> 
> Let's just not root squash.  The risk is pretty low since the pseudofs
> is readonly, and we'd rather not risk failing a mount unnecessarily.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
My apologies for taking so long to get to this... I lost it in the weeds ;-)

Both patches Committed!

steved. 
> ---
>  utils/mountd/v4root.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
> index 39dd87a94e59..c42ba72380ea 100644
> --- a/utils/mountd/v4root.c
> +++ b/utils/mountd/v4root.c
> @@ -34,7 +34,7 @@ static nfs_export pseudo_root = {
>  	.m_export = {
>  		.e_hostname = "*",
>  		.e_path = "/",
> -		.e_flags = NFSEXP_READONLY | NFSEXP_ROOTSQUASH
> +		.e_flags = NFSEXP_READONLY
>  				| NFSEXP_NOSUBTREECHECK | NFSEXP_FSID
>  				| NFSEXP_V4ROOT | NFSEXP_INSECURE_PORT,
>  		.e_anonuid = 65534,
> @@ -60,8 +60,6 @@ set_pseudofs_security(struct exportent *pseudo)
>  	struct flav_info *flav;
>  	int i;
>  
> -	if ((flags & NFSEXP_ROOTSQUASH) == 0)
> -		pseudo->e_flags &= ~NFSEXP_ROOTSQUASH;
>  	for (flav = flav_map; flav < flav_map + flav_map_size; flav++) {
>  		struct sec_entry *new;
>  
> 

