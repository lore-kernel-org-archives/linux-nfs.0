Return-Path: <SRS0=azWf=RW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE71EC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 15:03:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9EE9820850
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 15:03:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="WkttnIsj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726857AbfCSPDF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Mar 2019 11:03:05 -0400
Received: from sonic310-30.consmr.mail.ne1.yahoo.com ([66.163.186.211]:42362
        "EHLO sonic310-30.consmr.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726876AbfCSPDE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2019 11:03:04 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1553007783; bh=8eLDNP09NKHtb6NKCYkbHfriJ1YDJnmcG+IWUIIPBv8=; h=Subject:To:Cc:References:From:Date:In-Reply-To:From:Subject; b=WkttnIsjw2rQEQWwCEPKQJhxjki53j4LZYFvJW2pQ0+ptuInKOzNW5F1+L4I6etBeV1ocq3JA2bLk/TPV+LvXnTssXOd4ATRhjmsqRXOhX02LhUvuucQtlwo3KzO5uIaQYTFK4uwepi5cjgb22TKLX5NSFSYYPZCSp5XOxn2XVosXpRxItLSFy1A/dSTjZHgHoF5vmIHNwlExPKV8TeS49/6tVy4ddAXCTVfqOoIt7s5aMPpI6jFnkU5ZnwIRHWmg1HIXBknNvBZYifyzFASdLHmY+rBjsMZ2FJVrPWs2WTQLKPrhsGNZYiuZH/TKtP7tBTXlF2Dp/5d7Dv165FJdA==
X-YMail-OSG: lfg7TroVM1mnAKETjHG4PAgpnkk.fgSnZhWVqK1FkMlzaTOG4BpRN.sIHkA3Mb_
 1_NzOUE3bvJmHUmDtkYZ.kVgv9wUmw94pP27QT0RJ4d1G7KfaEDImSPkRS8crhRUHJaUanbaA2aQ
 fVIyMViTojLp7socja5glXFbHaX_mHqVhlCZ8l0GKoWoz3iF9_RkVtmlL.U2RLrm_bcwdSF7Nix1
 cwFXvVRIAS39JWVeUOBoEzfpFNVhEU8W_HDapcMba2TzcP9_jQXwNS2DmvCDtGYhK6nj6cLX6PDl
 pB7aAiblCTMA8JqBDZnxoN4oSkcRqMZfL2qT0w4gr7mI60ARKmHfvgk.ogaq7Zk_x5fztUirnzCs
 Lv14t554TB8BgcA7W73O65sUo.nLCS9tjAhmLRluW32sbv.uaeXb8vj8gyktKQ9BR6e.1gbo2eqa
 B00yj1jTIOtq349fhicZLqHAN5br7277bTjjhT6HHiHe_o5gdZpO1y6RcWvEwezKaySys3liKuI5
 LruFRpQNN8WgFpD0bJCtecuBAWEjJ2QRABa7FfDUXEBmV6I6DS9TLhPkZdKecKh7Ps2agf2LhxB2
 S1NuI5nkUUcPWVC6dZg8l2llL2IoiBt4waqAlCxCiaEzUt6GtpSxWiuAfv9683xdbF9vrL.m.xOX
 UGlYa7ydVf2nG1d9EzZGkLTqYb.8IMUDr4V59Ofx5DdE4qtwRJndLDD.DMG5fc8sOICqDxdnVBsd
 f9iIK8ZT4UCoVfMABKoJyBJ5CqRFBOtSJgIlb9MK3NllLrAFMXnWEplCu.DzdL5ewSMzJUxkrIkl
 WPuxo6ZLWFqlXeFZo8glPwcNWwzfqP0h7H6dD_j2gwp5qm9tQPDEsrlsQUzKQ_ylDFJjDAzP0Zgf
 rx7VM79tE9hfAdGpyeq2m.HFZIOFyDyGSHnf_3C8fKgyQ5fJGm5yNb0UgND5rsCaZLUp8VS1wJRo
 cVw5gDLGB8dKIWHwKz4zaDG3zbhcoJNZyIuqjUgwBSV_QWVSsbCjoLoZkkxkKVPDvh.tDzmREdWk
 kuz5Beia72UxmgoHwEU5T2bPUDuFz0YeFf47E.JdcU8NO1tP2MeXNAr_NuxVoHTNWzsHbaMMBE1W
 p2PC7FyxL.9xOIhm57fGSsWf5wTgIX19G1na.dcul
Received: from sonic.gate.mail.ne1.yahoo.com by sonic310.consmr.mail.ne1.yahoo.com with HTTP; Tue, 19 Mar 2019 15:03:03 +0000
Received: from c-67-169-65-224.hsd1.ca.comcast.net (EHLO [192.168.0.103]) ([67.169.65.224])
          by smtp417.mail.ne1.yahoo.com (Oath Hermes SMTP Server) with ESMTPA ID 2f9b5d50a452cf0c127cb7cfad7d058a;
          Tue, 19 Mar 2019 15:03:01 +0000 (UTC)
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
To:     Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
        Kees Cook <keescook@chromium.org>
Cc:     Jakub Kicinski <jakub.kicinski@netronome.com>,
        linux-security-module <linux-security-module@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        LKML <linux-kernel@vger.kernel.org>
References: <20190315110555.0807d015@cakuba.netronome.com>
 <20190315120105.5541ad46@cakuba.netronome.com>
 <20190315165440.53b9db3c@cakuba.netronome.com>
 <CAGXu5jKHRPuaALQcPXvpDeuVgZR+EeRqo9Qj4j3kYatb3HUSSA@mail.gmail.com>
 <CAGXu5jL-e7bDEXfpUuT-HyFarR-8T0djXChR0cuzTwFQPQ0tOw@mail.gmail.com>
 <f23d0fad-dc72-0e53-cac6-31abfd12a050@I-love.SAKURA.ne.jp>
 <bee1a774-461a-2535-a640-bbe65291e909@schaufler-ca.com>
 <2bf23acd-22c4-a260-7648-845887a409d5@i-love.sakura.ne.jp>
From:   Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <b00a3b2e-f603-331a-ef72-de59db288b90@schaufler-ca.com>
Date:   Tue, 19 Mar 2019 08:03:01 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <2bf23acd-22c4-a260-7648-845887a409d5@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 3/19/2019 3:56 AM, Tetsuo Handa wrote:
> Since Kees Cook seems to be busy now, here is my version...
>
>  From 885553e4793d9af2d4e9e99c7d137b0ec7b5f8ad Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 19 Mar 2019 19:52:31 +0900
> Subject: [PATCH] LSM: Revive CONFIG_DEFAULT_SECURITY_* for "make oldconfig"
>
> Commit 70b62c25665f636c ("LoadPin: Initialize as ordered LSM") removed
> CONFIG_DEFAULT_SECURITY_{SELINUX,SMACK,TOMOYO,APPARMOR,DAC} from
> security/Kconfig and changed CONFIG_LSM to provide a fixed ordering as a
> default value. That commit expected that existing users (upgrading from
> Linux 5.0 and earlier) will edit CONFIG_LSM value in accordance with
> their CONFIG_DEFAULT_SECURITY_* choice in their old kernel configs. But
> since users might forget to edit CONFIG_LSM value, this patch revives
> the choice (only for providing the default value for CONFIG_LSM) in order
> to make sure that CONFIG_LSM reflects CONFIG_DEFAULT_SECURITY_* from their
> old kernel configs.
>
> Reported-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Casey Schaufler <casey@schaufler-ca.com>


> ---
>   security/Kconfig | 36 +++++++++++++++++++++++++++++++++++-
>   1 file changed, 35 insertions(+), 1 deletion(-)
>
> diff --git a/security/Kconfig b/security/Kconfig
> index 1d6463f..743e594 100644
> --- a/security/Kconfig
> +++ b/security/Kconfig
> @@ -239,9 +239,43 @@ source "security/safesetid/Kconfig"
>   
>   source "security/integrity/Kconfig"
>   
> +choice
> +	prompt "Default security module [superseded by 'Ordered list of enabled LSMs' below]"
> +	default DEFAULT_SECURITY_SELINUX if SECURITY_SELINUX
> +	default DEFAULT_SECURITY_SMACK if SECURITY_SMACK
> +	default DEFAULT_SECURITY_TOMOYO if SECURITY_TOMOYO
> +	default DEFAULT_SECURITY_APPARMOR if SECURITY_APPARMOR
> +	default DEFAULT_SECURITY_DAC
> +
> +	help
> +	  This choice is there only for converting CONFIG_DEFAULT_SECURITY in old
> +	  kernel config to CONFIG_LSM in new kernel config. Don't change this choice
> +	  unless you are creating a fresh kernel config, for this choice will be
> +	  ignored after CONFIG_LSM is once defined.
> +
> +	config DEFAULT_SECURITY_SELINUX
> +		bool "SELinux" if SECURITY_SELINUX=y
> +
> +	config DEFAULT_SECURITY_SMACK
> +		bool "Simplified Mandatory Access Control" if SECURITY_SMACK=y
> +
> +	config DEFAULT_SECURITY_TOMOYO
> +		bool "TOMOYO" if SECURITY_TOMOYO=y
> +
> +	config DEFAULT_SECURITY_APPARMOR
> +		bool "AppArmor" if SECURITY_APPARMOR=y
> +	config DEFAULT_SECURITY_DAC
> +		bool "Unix Discretionary Access Controls"
> +
> +endchoice
> +
>   config LSM
>   	string "Ordered list of enabled LSMs"
> -	default "yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor"
> +	default "yama,loadpin,safesetid,integrity,selinux" if DEFAULT_SECURITY_SELINUX
> +	default "yama,loadpin,safesetid,integrity,smack" if DEFAULT_SECURITY_SMACK
> +	default "yama,loadpin,safesetid,integrity,tomoyo" if DEFAULT_SECURITY_TOMOYO
> +	default "yama,loadpin,safesetid,integrity,apparmor" if DEFAULT_SECURITY_APPARMOR
> +	default "yama,loadpin,safesetid,integrity"
>   	help
>   	  A comma-separated list of LSMs, in initialization order.
>   	  Any LSMs left off this list will be ignored. This can be
