Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:51349 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbaDCRrr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Apr 2014 13:47:47 -0400
Received: by mail-qc0-f179.google.com with SMTP id m20so2294626qcx.10
        for <linux-nfs@vger.kernel.org>; Thu, 03 Apr 2014 10:47:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140403174339.GA284@x4>
References: <20140403174339.GA284@x4>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 3 Apr 2014 10:47:26 -0700
Message-ID: <CALCETrVYvCWngDsWnEY9OuJrf=nWYCyb-avrz083ddbKxO7TjQ@mail.gmail.com>
Subject: Re: [PATCH] x86, vdso: Fix vdso-layout linker script
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: linux-nfs@vger.kernel.org, "H. Peter Anvin" <hpa@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 3, 2014 at 10:43 AM, Markus Trippelsdorf
<markus@trippelsdorf.de> wrote:
> Commit 26f5ef2e3c3 added a /DISCARD/ section to the vdso-layout.lds.S
> linker script. This broke the build when using the gold linker:
>
>  ld: error: arch/x86/vdso/vdso.lds:79:12: syntax error, unexpected ':'
>  ld: fatal error: unable to parse script file arch/x86/vdso/vdso.lds
>
> As Cary Coutant pointed out on the sourceware bugzilla:
> https://sourceware.org/bugzilla/show_bug.cgi?id=16804
> the problem is that the .text section directly above the /DISCARD/
> section should be terminated with an comma.
>
> Signed-off-by: Markus Trippelsdorf <markus@trippelsdorf.de>

This patch triggers an internal error in whatever version of gold I'm
using.  I'll send a variant of the patch when I finish testing it.

>
> diff --git a/arch/x86/vdso/vdso-layout.lds.S b/arch/x86/vdso/vdso-layout.lds.S
> index 2e263f367b13..313bca59ddea 100644
> --- a/arch/x86/vdso/vdso-layout.lds.S
> +++ b/arch/x86/vdso/vdso-layout.lds.S
> @@ -61,7 +61,7 @@ SECTIONS
>          */
>         . = ALIGN(0x100);
>
> -       .text           : { *(.text*) }                 :text   =0x90909090
> +       .text           : { *(.text*) }                 :text   =0x90909090,
>
>         /DISCARD/ : {
>                 *(.discard)
> --
> Markus



-- 
Andy Lutomirski
AMA Capital Management, LLC
