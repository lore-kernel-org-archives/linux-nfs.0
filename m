Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4C95C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 22:06:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0FD1A2064C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 22:06:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="XWtYx3hX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FD1A2064C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727854AbeKBHL3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 03:11:29 -0400
Received: from mail-ed1-f66.google.com ([209.85.208.66]:41322 "EHLO
        mail-ed1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726273AbeKBHL3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 03:11:29 -0400
Received: by mail-ed1-f66.google.com with SMTP id c25-v6so327765edt.8
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 15:06:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=rasmusvillemoes.dk; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=6ed9imu7MAL40rWT9ilf3h/y4a36MzzVAFx5Si5DDSg=;
        b=XWtYx3hXMxjmF8Hqo5Oek2Qe8H+pgd18DAFI1Jzhtie5ixD9ZMm6mNLjqdJy9PCWgP
         XRoVklKQQCWyXTAhX3iVsggmQt1rNc8FYL4U+Kh7bMekm7hMl+lavDb596CGEnZrIPe3
         uTxG7klvUrU1NiUjSx3Aaj72MYqM67trNZOcs=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=6ed9imu7MAL40rWT9ilf3h/y4a36MzzVAFx5Si5DDSg=;
        b=OYKqol9sPjrFT+HDOK5DVj/gjeJU6x+IbvsOPsaTzbrzWQzC2NvjvDTQTRxLsm+5nm
         AQhRaWr8syR3Ml6pUJNfd78EfyGCpHxdHR6CfJzdKWkYD48eURoOMoEOGXzFA4o3DzUv
         r/ySfhd85Tyemq1mZvOnCG2ddZwv/1kHKcuHX3n/S/ZVAi5MvoEIiJ0PWu0RuuclAr/O
         7MTXbzIiq+ruuQysjwEzfTbuI2/9A4Gyw77ghG42alcC7+8b6EZtXvSzwvBRS0aB1jqj
         m0GsljIY9Knyxc0xEKlZ8wpuQGOGjWwOYCMNLWUOmf1AhuMS6PnVHmwnpd2TwjNXLTcx
         e/+A==
X-Gm-Message-State: AGRZ1gKCbACABPTy2oBG9TIcFDmNt/rwMoMkbKnH9IPfARtmGDj2GluD
        CuphQnvR36ztRgWGWvk9YoEMus4ie7zayw==
X-Google-Smtp-Source: AJdET5db9lVDO0KtJ3OffvqdS5JA/WGfjmIi/sBjndaQlHfCbn8MPoV7DTNwk38Odftf3Sv/HN0zXA==
X-Received: by 2002:a50:ce5e:: with SMTP id k30-v6mr6105169edj.207.1541109996329;
        Thu, 01 Nov 2018 15:06:36 -0700 (PDT)
Received: from [192.168.0.189] (dhcp-5-186-114-252.cgn.ip.fibianet.dk. [5.186.114.252])
        by smtp.gmail.com with ESMTPSA id g15-v6sm5596504ejj.67.2018.11.01.15.06.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 15:06:35 -0700 (PDT)
Subject: Re: [RFC PATCH 0/7] runtime format string checking
To:     Kees Cook <keescook@chromium.org>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        linux-hwmon@vger.kernel.org,
        Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>,
        "Steven Rostedt (VMware)" <rostedt@goodmis.org>,
        Jean Delvare <jdelvare@suse.com>,
        Guenter Roeck <linux@roeck-us.net>
References: <20171108223020.24487-1-linux@rasmusvillemoes.dk>
 <20181026232409.16100-1-linux@rasmusvillemoes.dk>
 <CAGXu5j+eGQ3oo_1qSwW-BEVSK=vcLmNLWH8E7fPiawobo=_fbQ@mail.gmail.com>
From:   Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <63e10688-5207-e8a4-dac2-d6c6094fbcc2@rasmusvillemoes.dk>
Date:   Thu, 1 Nov 2018 23:06:23 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+eGQ3oo_1qSwW-BEVSK=vcLmNLWH8E7fPiawobo=_fbQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2018-10-30 21:58, Kees Cook wrote:
> On Sat, Oct 27, 2018 at 12:24 AM, Rasmus Villemoes
> <linux@rasmusvillemoes.dk> wrote:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/commit/?h=kspp/format-security&id=ce9b938574042d09920650cb3c63ec29658edc87
> The above seemed to "noisy" to send, but perhaps we should just land
> it anyway. They really _should_ be const.
>

Isn't that 063246641d4a9e9de84a2466fbad50112faf88dc in mainline ;) ?
BTW, I don't agree with all the changes in there: For auto variables, this

-       const char *cur_drv, *drv = "acpi-cpufreq";
+       const char drv[] = "acpi-cpufreq";
+       const char *cur_drv;

makes gcc actually generate that string on the stack instead of just
referring to an anonymous object in .rodata; one gets code gen like

+:      31 c0                   xor    %eax,%eax
+:      48 b8 61 63 70 69 2d    movabs $0x7570632d69706361,%rax # "acpi-cpu"
+:      63 70 75
+:      c7 44 24 0b 66 72 65    movl   $0x71657266,0xb(%rsp) # "freq"
+:      71
+:      c6 44 24 0f 00          movb   $0x0,0xf(%rsp) "\0"
+:      48 89 44 24 03          mov    %rax,0x3(%rsp)

It's not the-end-of-the-world-horrible, but it's better avoided,
especially for patches that are not supposed to change anything. And
longer strings would of course produce even more gunk like the above.
A better fix which also silences -Wformat-security is to declare the
variable itself const, i.e.

const char *const drv = "acpi-cpufreq".

Yes, gcc should be able to infer the constness of drv from the fact that
it's never assigned to elsewhere in the function... I think I saw that
on some gcc todo list at some point.


> https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/commit/?h=kspp/format-security&id=b7dcfc8f48caaafcc423e5793f7ef61b9bb5c458
> This one covers cases where the pointer is pointing to a const string,
> so really there's no sense in injecting the "%s", but I was collecting
> them to make real ones stand out.

I don't agree. Yes, a human can verify that _currently_, only "pencrypt"
and "pdecrypt" can ever reach pcrypt_sysfs_add(). But without the
compiler being smart enough to do that, one will never know if some new
caller shows up, or one of those literals grows a % for some reason.
Adding "%s" doesn't cost much, especially not in cases (like this one)
where the fmt+args end up at kobject_set_name_vargs - for a "%s" +
literal that does a (succesful) kstrdup_const(), so we never even hit
the vsnprintf() engine.

>> Patches 5,6,7 are
>> some examples of where one might add fmtcheck() calls. I don't think
>> we can get to a state where we can unconditionally add
>> -Wformat-nonliteral to the build, but I think there's a lot of
>> low-hanging fruit.
> 
> How much work do you think it'd take to get to a
> format-nonliteral-clean build? I think it's worth doing the work if
> it's not totally intractable.

Probably less than the VLA removal. But it kind of depends on which
tools one allows. I can't see how to do it without something like
fmtcheck() to annotate certain places (e.g. the nfs example). Maybe a
no_fmtcheck() to annotate places which have been manually verified
[modulo the above "but that may change..."] would also be needed
(no_fmtcheck would be the same as fmtcheck for at !CONFIG_FMTCHECK
kernel), similar to how we have no_printk.

I kind of agree with Guenther that the hwmon example is a bad one. It
would be better to have the compiler check all those string literals
against a pattern at build time. Probably the format template plugin can
be extended to apply to any "const char*" declaration, not just those
sitting inside structs. But I'd rather get fmtcheck() in first before
returning to work on that plugin.

Rasmus
