Return-Path: <SRS0=ELWp=WI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F97CC433FF
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Aug 2019 17:36:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E700D2067D
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Aug 2019 17:36:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726263AbfHLRgE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Aug 2019 13:36:04 -0400
Received: from mx1.redhat.com ([209.132.183.28]:41286 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725843AbfHLRgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Aug 2019 13:36:04 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1E31B30BBE89;
        Mon, 12 Aug 2019 17:36:04 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-116-63.phx2.redhat.com [10.3.116.63])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C697A5030E;
        Mon, 12 Aug 2019 17:36:03 +0000 (UTC)
Subject: Re: [PATCH nfs-utils] gssd: Look in lib32 for gss libs aswell.
To:     Matt Turner <mattst88@gmail.com>, linux-nfs@vger.kernel.org
References: <20190811221044.13777-1-mattst88@gmail.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <52117616-0de9-c94b-5539-215570ae4d46@RedHat.com>
Date:   Mon, 12 Aug 2019 13:36:03 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190811221044.13777-1-mattst88@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 12 Aug 2019 17:36:04 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 8/11/19 6:10 PM, Matt Turner wrote:
> Akin to commit da999b81b058 ("Look in lib64 for gss libs aswell.")
> 
> mips/n32 systems have libraries in lib32 (but not lib or lib64). Without
> checking lib32, configure fails with
> 
> checking for Kerberos v5... configure: error: Kerberos v5 with GSS
>          support not found: consider --disable-gss or --with-krb5=
> 
> Signed-off-by: Matt Turner <mattst88@gmail.com>
Committed!

steved.

> ---
>  aclocal/kerberos5.m4 | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/aclocal/kerberos5.m4 b/aclocal/kerberos5.m4
> index 8a0f3e4c..faa58049 100644
> --- a/aclocal/kerberos5.m4
> +++ b/aclocal/kerberos5.m4
> @@ -38,9 +38,11 @@ AC_DEFUN([AC_KERBEROS_V5],[
>        AC_DEFINE_UNQUOTED(KRB5_VERSION, $K5VERS, [Define this as the Kerberos version number])
>        if test -f $dir/include/gssapi/gssapi_krb5.h -a \
>                  \( -f $dir/lib/libgssapi_krb5.a -o \
> +                   -f $dir/lib/libgssapi_krb5.so -o \
> +                   -f $dir/lib32/libgssapi_krb5.a -o \
> +                   -f $dir/lib32/libgssapi_krb5.so -o \
>                     -f $dir/lib64/libgssapi_krb5.a -o \
> -                   -f $dir/lib64/libgssapi_krb5.so -o \
> -                   -f $dir/lib/libgssapi_krb5.so \) ; then
> +                   -f $dir/lib64/libgssapi_krb5.so \) ; then
>           AC_DEFINE(HAVE_KRB5, 1, [Define this if you have MIT Kerberos libraries])
>           KRBDIR="$dir"
>           gssapi_lib=gssapi_krb5
> 
