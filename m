Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 235CAC0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 22:57:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CEA5120657
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 22:57:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="jYcqpvMa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEA5120657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727775AbeKBICV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 04:02:21 -0400
Received: from mail-yb1-f193.google.com ([209.85.219.193]:40314 "EHLO
        mail-yb1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727997AbeKBICV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 04:02:21 -0400
Received: by mail-yb1-f193.google.com with SMTP id g9-v6so45333ybh.7
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 15:57:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=piJz5wwwDIMNKXTj9UJQjfcS9dm7aj2ijGtQlGYWaqk=;
        b=jYcqpvMaesyUvpyX8eMosiaiPtjkqb789aPuaBz+nQCKvWHQLfjeyjh8OXK7bDKS0P
         dI6WSFTV/E/gXq9XhZ476nJI2GquSkzcM42iaNIah1qO6U0TC8kC804TFHlilqOi2bpo
         wbIQLLKdTdFRQyGdgmmknmm4qNy0ttwAkzCM0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:in-reply-to:references:from:date
         :message-id:subject:to:cc;
        bh=piJz5wwwDIMNKXTj9UJQjfcS9dm7aj2ijGtQlGYWaqk=;
        b=Ur4U0iEFHzb+JrwZZczJnVWDq1RGLbRxYemG9+iSWVSX5M8QCgalpobUh2BOGcrzC9
         Oqv9JRkLm3Tnt15zGUSMoBuRr3IfJwUr2MI955FvyvS9MefmSth7VtqbJIF3Gy3ivq9d
         RbTeFLlCjzvaEi6xFDBT/QzgWl01inIXzrO2tqKsnwhdmrYFQS98udLodPY0vuF4155J
         XAK3QSuaDcG0K7gJf0fplL10joB8oUmSfHGEPTPd8hWHkZseOGyhyGfDMaag/n/oCLvg
         RYIISwu2kykJduvi/DLPp2ZMGHaQIIBf4NVZOrEXohGgT7A4GsnKIm6hfVqICLAtCjip
         ZMtQ==
X-Gm-Message-State: AGRZ1gLRf2HEe8vKnLCXqAYoyZe9PD0uCVQzuLOG9o3oiLISs2HC14qS
        rubkaHB2geddYLZXLX7KUEg1hSpT5MU=
X-Google-Smtp-Source: AJdET5fUljC+CVtKaJEWHd2w9HAbhGjUuCFB3/56IW67+7/g4+smx75wqQUJPLqyYJpqonoErgt3xA==
X-Received: by 2002:a25:c241:: with SMTP id s62-v6mr3144699ybf.515.1541113040510;
        Thu, 01 Nov 2018 15:57:20 -0700 (PDT)
Received: from mail-yb1-f178.google.com (mail-yb1-f178.google.com. [209.85.219.178])
        by smtp.gmail.com with ESMTPSA id 123-v6sm7854076ywx.15.2018.11.01.15.57.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 15:57:18 -0700 (PDT)
Received: by mail-yb1-f178.google.com with SMTP id i78-v6so61642ybg.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 15:57:18 -0700 (PDT)
X-Received: by 2002:a25:8409:: with SMTP id u9-v6mr9672196ybk.421.1541113038015;
 Thu, 01 Nov 2018 15:57:18 -0700 (PDT)
MIME-Version: 1.0
Received: by 2002:a25:3990:0:0:0:0:0 with HTTP; Thu, 1 Nov 2018 15:57:17 -0700 (PDT)
In-Reply-To: <63e10688-5207-e8a4-dac2-d6c6094fbcc2@rasmusvillemoes.dk>
References: <20171108223020.24487-1-linux@rasmusvillemoes.dk>
 <20181026232409.16100-1-linux@rasmusvillemoes.dk> <CAGXu5j+eGQ3oo_1qSwW-BEVSK=vcLmNLWH8E7fPiawobo=_fbQ@mail.gmail.com>
 <63e10688-5207-e8a4-dac2-d6c6094fbcc2@rasmusvillemoes.dk>
From:   Kees Cook <keescook@chromium.org>
Date:   Thu, 1 Nov 2018 15:57:17 -0700
X-Gmail-Original-Message-ID: <CAGXu5jL6RCL=WvCBJQytw=KnN74dp=1gd5wO-fO3i8tjAT=pvw@mail.gmail.com>
Message-ID: <CAGXu5jL6RCL=WvCBJQytw=KnN74dp=1gd5wO-fO3i8tjAT=pvw@mail.gmail.com>
Subject: Re: [RFC PATCH 0/7] runtime format string checking
To:     Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        linux-hwmon@vger.kernel.org,
        Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>,
        "Steven Rostedt (VMware)" <rostedt@goodmis.org>,
        Jean Delvare <jdelvare@suse.com>,
        Guenter Roeck <linux@roeck-us.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 1, 2018 at 3:06 PM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> On 2018-10-30 21:58, Kees Cook wrote:
>> On Sat, Oct 27, 2018 at 12:24 AM, Rasmus Villemoes
>> <linux@rasmusvillemoes.dk> wrote:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/commit/?h=kspp/format-security&id=ce9b938574042d09920650cb3c63ec29658edc87
>> The above seemed to "noisy" to send, but perhaps we should just land
>> it anyway. They really _should_ be const.
>>
>
> Isn't that 063246641d4a9e9de84a2466fbad50112faf88dc in mainline ;) ?

Oh, hah, so it is. So long ago I forgot. :P

> BTW, I don't agree with all the changes in there: For auto variables, this
>
> -       const char *cur_drv, *drv = "acpi-cpufreq";
> +       const char drv[] = "acpi-cpufreq";
> +       const char *cur_drv;
>
> makes gcc actually generate that string on the stack instead of just
> referring to an anonymous object in .rodata; one gets code gen like
>
> +:      31 c0                   xor    %eax,%eax
> +:      48 b8 61 63 70 69 2d    movabs $0x7570632d69706361,%rax # "acpi-cpu"
> +:      63 70 75
> +:      c7 44 24 0b 66 72 65    movl   $0x71657266,0xb(%rsp) # "freq"
> +:      71
> +:      c6 44 24 0f 00          movb   $0x0,0xf(%rsp) "\0"
> +:      48 89 44 24 03          mov    %rax,0x3(%rsp)

Oh that is nasty. Ugh. I hate the "const but not really ha ha" optimizations. :(

> It's not the-end-of-the-world-horrible, but it's better avoided,
> especially for patches that are not supposed to change anything. And
> longer strings would of course produce even more gunk like the above.
> A better fix which also silences -Wformat-security is to declare the
> variable itself const, i.e.
>
> const char *const drv = "acpi-cpufreq".

Yes, that would be much better. Seems like we could do a really easy
Coccinelle script to fix all of those?

@@
identifier VAR;
expression STRING;
@@

- const char VAR[]
+ const char * const VAR
  = STRING;

yields:
 517 files changed, 890 insertions(+), 891 deletions(-)

Worth doing at the end of -rc2?

> Yes, gcc should be able to infer the constness of drv from the fact that
> it's never assigned to elsewhere in the function... I think I saw that
> on some gcc todo list at some point.

If you find that bug, I'll add it to my gcc bug tracking list. :P

>> https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/commit/?h=kspp/format-security&id=b7dcfc8f48caaafcc423e5793f7ef61b9bb5c458
>> This one covers cases where the pointer is pointing to a const string,
>> so really there's no sense in injecting the "%s", but I was collecting
>> them to make real ones stand out.
>
> I don't agree. Yes, a human can verify that _currently_, only "pencrypt"
> and "pdecrypt" can ever reach pcrypt_sysfs_add(). But without the
> compiler being smart enough to do that, one will never know if some new
> caller shows up, or one of those literals grows a % for some reason.
> Adding "%s" doesn't cost much, especially not in cases (like this one)
> where the fmt+args end up at kobject_set_name_vargs - for a "%s" +
> literal that does a (succesful) kstrdup_const(), so we never even hit
> the vsnprintf() engine.

Okay, then I'll forward this to akpm maybe?

>>> Patches 5,6,7 are
>>> some examples of where one might add fmtcheck() calls. I don't think
>>> we can get to a state where we can unconditionally add
>>> -Wformat-nonliteral to the build, but I think there's a lot of
>>> low-hanging fruit.
>>
>> How much work do you think it'd take to get to a
>> format-nonliteral-clean build? I think it's worth doing the work if
>> it's not totally intractable.
>
> Probably less than the VLA removal. But it kind of depends on which
> tools one allows. I can't see how to do it without something like
> fmtcheck() to annotate certain places (e.g. the nfs example). Maybe a
> no_fmtcheck() to annotate places which have been manually verified
> [modulo the above "but that may change..."] would also be needed
> (no_fmtcheck would be the same as fmtcheck for at !CONFIG_FMTCHECK
> kernel), similar to how we have no_printk.
>
> I kind of agree with Guenther that the hwmon example is a bad one. It
> would be better to have the compiler check all those string literals
> against a pattern at build time. Probably the format template plugin can
> be extended to apply to any "const char*" declaration, not just those
> sitting inside structs. But I'd rather get fmtcheck() in first before
> returning to work on that plugin.

Yeah, fair.

-Kees

-- 
Kees Cook
