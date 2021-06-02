Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.9 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89323C4708F
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jun 2021 07:44:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6F674613AE
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jun 2021 07:44:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232049AbhFBHqZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jun 2021 03:46:25 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59586 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232046AbhFBHqY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jun 2021 03:46:24 -0400
Received: from mail-lf1-x12a.google.com (mail-lf1-x12a.google.com [IPv6:2a00:1450:4864:20::12a])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id AE230C061574
        for <linux-nfs@vger.kernel.org>; Wed,  2 Jun 2021 00:44:40 -0700 (PDT)
Received: by mail-lf1-x12a.google.com with SMTP id x38so1883657lfa.10
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jun 2021 00:44:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bell-sw-com.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=eVCfryPK9c1lV695W8KvQyZ//tca/B4ruVeWI919rA4=;
        b=NGTgQURsr0VhAXcCGY0XenNcIRciliarhNeKBdT9KX3Y45KOJ78oaj7pq+/Fvjm+Nj
         xFvYICY5hZwdEZbIuiEatXhZ+jJOwLBIcWUdhpDZ/AOQJUwDc0i7q05tt5i7aiMAbnPC
         LU1wuPXwiSHZYbOeAnZ/xKUJfm5sRGfBJiRC+hKE1IrgzBx+bbj6swphIZ7+Hpf7RWXs
         zND0Q9uQ4Lul+RqX23nZkG9ghqhEho7dGDbIeNAvmMXXsf1NHoyFpyFbmpjlSgJMFCEp
         2FaNRqIy+1x5sKP3t1Jr8GVPWiWsrAu6wT3N5xWmAuwWADMdjGVA4z6Eh8P6Yjkna4vF
         QBYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=eVCfryPK9c1lV695W8KvQyZ//tca/B4ruVeWI919rA4=;
        b=XLNgLqUhbpThauyQdslSQIJ6Wvf8QakeSfQ1VrR3AdAQWhZhitncBcAvxhYgve0FGM
         WaYRdZe/MWjRjcsbSgsVfmlqb059U1WltOel/7GaCd5a2XzHnjWXkkQJwhePId7AzrB2
         PFVN53ApvC/GLiSP087OiHzt+1RrJxnirdkFv3G0PEIjhJsdBswIE8RI9JZwOQCkLjiF
         w3cimf7CiAjmwG+OP/LayC69iptFIcQAXnDVnjimllH7DLIKIP0h151If3d1Zw20IK4b
         z+xiv+4tgUUBrune8Ix/wum8XQXzIdUOpCsTYPn6/S7XWddRQI2KLvgqnqJ02NxFsnV/
         UbxA==
X-Gm-Message-State: AOAM532NKoJJpqWzOB8EOaX7mtPGBXQl6//OuxXOTnSnizW16n9alLEE
        xFlpDnPwppeC4iKNm4oxYfFsJ1OpuY7j0zs=
X-Google-Smtp-Source: ABdhPJzaNvxWQ6NIpL3BdvU7VQHxjbApqn8A9/uNgl5E0nyb2pY/NUpmR+Ieu51klKiao3bd5vswjA==
X-Received: by 2002:ac2:414f:: with SMTP id c15mr893963lfi.307.1622619878905;
        Wed, 02 Jun 2021 00:44:38 -0700 (PDT)
Received: from [192.168.1.52] ([95.161.221.177])
        by smtp.gmail.com with ESMTPSA id r17sm1924502lfr.18.2021.06.02.00.44.38
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 02 Jun 2021 00:44:38 -0700 (PDT)
Subject: Re: [LTP PATCH v2 1/3] nfs_lib.sh: Detect unsupported protocol
To:     Petr Vorel <pvorel@suse.cz>, ltp@lists.linux.it
Cc:     linux-nfs@vger.kernel.org
References: <20210526172503.18621-1-pvorel@suse.cz>
From:   Alexey Kodanev <aleksei.kodanev@bell-sw.com>
Message-ID: <210e1e4f-23d8-6a8b-18cb-ea7a4e7f89c2@bell-sw.com>
Date:   Wed, 2 Jun 2021 10:44:38 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.8.1
MIME-Version: 1.0
In-Reply-To: <20210526172503.18621-1-pvorel@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 26.05.2021 20:25, Petr Vorel wrote:
> Caused by disabled CONFIG_NFSD_V[34] in kernel config.
> 
> Signed-off-by: Petr Vorel <pvorel@suse.cz>
> ---
> new in v2
> 
>  testcases/network/nfs/nfs_stress/nfs_lib.sh | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/testcases/network/nfs/nfs_stress/nfs_lib.sh b/testcases/network/nfs/nfs_stress/nfs_lib.sh
> index 3fad8778a..b80ee0e18 100644
> --- a/testcases/network/nfs/nfs_stress/nfs_lib.sh
> +++ b/testcases/network/nfs/nfs_stress/nfs_lib.sh
> @@ -94,9 +94,15 @@ nfs_mount()
>  
>  	if [ $? -ne 0 ]; then
>  		cat mount.log
> +
>  		if [ "$type" = "udp" -o "$type" = "udp6" ] && tst_kvcmp -ge 5.6; then
>  			tst_brk TCONF "UDP support disabled with the kernel config NFS_DISABLE_UDP_SUPPORT?"
>  		fi
> +
> +		if grep -i "Protocol not supported" mount.log; then

Hi Petr,

It's better to add '-q' flag to grep.

> +			tst_brk TCONF "Protocol not supported"
> +		fi
> +
>  		tst_brk TBROK "mount command failed"
>  	fi
>  }
> 

