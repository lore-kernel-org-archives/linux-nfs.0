Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55326 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844AbbBZTgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 14:36:00 -0500
Message-ID: <54EF759B.5000800@RedHat.com>
Date: Thu, 26 Feb 2015 14:35:55 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?windows-1252?Q?Aur=E9lien_Chabot?= <aurelien@chabot.fr>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix systemd autotools activation option
References: <1424627104-22639-1-git-send-email-aurelien@chabot.fr>
In-Reply-To: <1424627104-22639-1-git-send-email-aurelien@chabot.fr>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/22/2015 12:45 PM, Aurélien Chabot wrote:
> The option to activate the install of systemd service files was never
> taken into account.
> ---
>  configure.ac | 1 -
>  1 file changed, 1 deletion(-)
Committed! 

steved.

> 
> diff --git a/configure.ac b/configure.ac
> index 8e427e3..e61430f 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -60,7 +60,6 @@ AC_ARG_WITH(systemd,
>  	[AC_HELP_STRING([--with-systemd@<:@=unit-dir-path@:>@],
>  			[install systemd unit files @<:@Default: no, and path defaults to /usr/lib/systemd/system if not given@:>@])],
>  	test "$withval" = "no" && use_systemd=0 || unitdir=$withval use_systemd=1
> -	use_systemd=0
>  	)
>  	AM_CONDITIONAL(INSTALL_SYSTEMD, [test "$use_systemd" = 1])
>  	AC_SUBST(unitdir)
> 
