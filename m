Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C36DC433EF
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Feb 2022 16:49:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235708AbiBWQsg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Feb 2022 11:48:36 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60866 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233905AbiBWQsf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2022 11:48:35 -0500
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTP id D23B836B5B
        for <linux-nfs@vger.kernel.org>; Wed, 23 Feb 2022 08:48:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1645634886;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=dPVCzM3xV0185YFcgo/1aEes0i2MZEq6PuLz2/3hjCE=;
        b=QB/AJY57Wk8PZfacT9XUvmfrXPF53Y2vsIXofw0ACLvixwRetgNW3o5O+ZWXdoS9ezXUg7
        6qTjAfkzk4G3e9QtuxZK4YbMV54Z2wpmoQxBd+lpA27C2MO/XjdkNInhdRmfOAo/ennK6O
        cTzPoOmvEQygagVMxJ+ElaiT3YDFv8U=
Received: from mail-qv1-f72.google.com (mail-qv1-f72.google.com
 [209.85.219.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-133-5V8nkJ6XNv63EyEIFMrpqg-1; Wed, 23 Feb 2022 11:48:05 -0500
X-MC-Unique: 5V8nkJ6XNv63EyEIFMrpqg-1
Received: by mail-qv1-f72.google.com with SMTP id w14-20020a0cfc4e000000b0042c1ac91249so4373868qvp.4
        for <linux-nfs@vger.kernel.org>; Wed, 23 Feb 2022 08:48:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:from:to:references:in-reply-to
         :content-transfer-encoding;
        bh=dPVCzM3xV0185YFcgo/1aEes0i2MZEq6PuLz2/3hjCE=;
        b=j0fcfY4bJ9ODxETRC55qH0o2G+6nHi1GKVmYOYAu3nhVAnuZqkwp3sKCAeLdc8b7Hz
         x7nwKijasnNl2wXYMYroQMjxxMkUjLNlxFNm4KMunIvKlN9c0V2OTXjIzphNdhUxbS8Y
         IGinS3uQ2WtsCQh8OVYHZc/uXf+aiSWwG34fPRrwyyiYk2KmnU9sBOpZwCfOEVS8WH3U
         tpUCqg/d3+HQUYg/93t+AjH60HSVykk4ByG04cqY9wRTiMLqjhTiaSgUhZ9yiO5Uo6Ju
         6Ls0QD6S55+8bgogWVshGFlCOWrlwRq7CUEXYIQDDYKhtGWa4qjUZ3eafPNDFQJE25Cy
         ySlw==
X-Gm-Message-State: AOAM530rL3/QEzKxa8hBxlEiQ3YPUMMr0cptVZ0OK2b9iVxAb7Sq1N36
        AzdHEaWQx9LmlM8OSxYveu4gAFcm48Wc80nNVNajjvbXs2V40L5R9sDnQETTP8lgnGymx+OvWs+
        qlCE2qxkSzDYh/lJjPdEcDZSlso3nDMwLvqe1XOZb91GsztEDROj7uM70SrE6HwCe7FfD3Q==
X-Received: by 2002:a37:6186:0:b0:60d:ed9c:6203 with SMTP id v128-20020a376186000000b0060ded9c6203mr363985qkb.172.1645634885008;
        Wed, 23 Feb 2022 08:48:05 -0800 (PST)
X-Google-Smtp-Source: ABdhPJz5M4JNIgPVLBoQyacW0VZf5vghgYen++jMU7DwckzWHHNy7Pt/3ro1/9/yn4VxopLpAWgNEw==
X-Received: by 2002:a37:6186:0:b0:60d:ed9c:6203 with SMTP id v128-20020a376186000000b0060ded9c6203mr363972qkb.172.1645634884614;
        Wed, 23 Feb 2022 08:48:04 -0800 (PST)
Received: from [172.31.1.6] ([71.161.196.139])
        by smtp.gmail.com with ESMTPSA id b6sm40616qkg.51.2022.02.23.08.48.04
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 23 Feb 2022 08:48:04 -0800 (PST)
Message-ID: <39888986-ccfe-0dfb-6429-ad7aceb4575a@redhat.com>
Date:   Wed, 23 Feb 2022 11:48:03 -0500
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.5.0
Subject: Re: [PATCH] mount.nfs: Fix Typo auto negotiating code.
Content-Language: en-US
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20220219164631.38534-1-steved@redhat.com>
In-Reply-To: <20220219164631.38534-1-steved@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 2/19/22 11:46 AM, Steve Dickson wrote:
> Commit 14258541 add a check that had a '||'
> instead of a '&&' which is the typo.
> 
> The intention of commit 14258541 was to show
> EBUSY errors but this error is not shown when
> the mount point does exists (commit afda50fc).
> 
> In the end, EBUSY are now interrupted correctly
> in this corner case.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... (tag: nfs-utils-2-6-2-rc2)

steved.
> ---
>   utils/mount/stropts.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 573df6e..dbdd11e 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -973,7 +973,7 @@ fall_back:
>   	if ((result = nfs_try_mount_v3v2(mi, FALSE)))
>   		return result;
>   
> -	if (errno != EBUSY || errno != EACCES)
> +	if (errno != EBUSY && errno != EACCES)
>   		errno = olderrno;
>   
>   	return result;

