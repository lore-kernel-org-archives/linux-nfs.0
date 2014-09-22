Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2921 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754679AbaIVTuQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 15:50:16 -0400
Message-ID: <54207D75.1080400@RedHat.com>
Date: Mon, 22 Sep 2014 15:50:13 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH 2/2] rpc.svcgssd: the build of rpc.svcgssd is off by default
References: <1411413608-16462-1-git-send-email-steved@redhat.com> <1411413608-16462-3-git-send-email-steved@redhat.com> <20140922194352.GF26763@fieldses.org>
In-Reply-To: <20140922194352.GF26763@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/22/2014 03:43 PM, J. Bruce Fields wrote:
> On Mon, Sep 22, 2014 at 03:20:08PM -0400, Steve Dickson wrote:
>> Due to the fact the gssproxy is not managing the
>> GASSAPI credentials, on the server, there is
>> no need to build/install rpc.svcgssd.
>>
>> To re-enable the build use the --enable-svcgss
>> configure flag
> 
> Since we're not running rpc.svcgssd in those cases where it's not
> needed, we should keep --enable-svcgss as the default for now.  It's an
> easy way to keep old kernels working.
Either way is fine with me... As long as there is a switch but 
I have to wonder out loud... 

How often is it the case where the the latest nfs-utils is being 
run on a a kernel that is over two years old... I guess I don't
see the point... 

steved.
> 
> --b.
> 
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  configure.ac           | 23 +++++++++++++++++++----
>>  utils/gssd/Makefile.am | 11 +++++++++--
>>  2 files changed, 28 insertions(+), 6 deletions(-)
>>
>> diff --git a/configure.ac b/configure.ac
>> index bc48373..6767190 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -90,21 +90,36 @@ AC_ARG_ENABLE(nfsv41,
>>  
>>  AC_ARG_ENABLE(gss,
>>  	[AC_HELP_STRING([--enable-gss],
>> -                        [enable support for rpcsec_gss @<:@default=yes@:>@])],
>> +              [enable client support for rpcsec_gss @<:@default=yes@:>@])],
>>  	enable_gss=$enableval,
>>  	enable_gss=yes)
>>  	if test "$enable_gss" = yes; then
>>  		GSSD=gssd
>> -		SVCGSSD=svcgssd
>>  	else
>>  		enable_gss=
>>  		GSSD=
>> -		SVCGSSD=
>>  	fi
>>  	AC_SUBST(GSSD)
>> -	AC_SUBST(SVCGSSD)
>>  	AC_SUBST(enable_gss)
>>  	AM_CONDITIONAL(CONFIG_GSS, [test "$enable_gss" = "yes"])
>> +
>> +AC_ARG_ENABLE(svcgss,
>> +	[AC_HELP_STRING([--enable-svcgss],
>> +              [enable server support for rpcsec_gss @<:@default=no@:>@])],
>> +	enable_svcgss=$enableval,
>> +	enable_svcgss=no)
>> +	if test "$enable_gss" = yes; then
>> +		if "enable_svcgss" = yes; then
>> +			SVCGSSD=svcgssd
>> +		fi
>> +	else
>> +		enable_svcgss=
>> +		SVCGSSD=
>> +	fi
>> +	AC_SUBST(SVCGSSD)
>> +	AC_SUBST(enable_svcgss)
>> +	AM_CONDITIONAL(CONFIG_SVCGSS, [test "$enable_svcgss" = "yes"])
>> +
>>  AC_ARG_ENABLE(kprefix,
>>  	[AC_HELP_STRING([--enable-kprefix], [install progs as rpc.knfsd etc])],
>>  	test "$enableval" = "yes" && kprefix=k,
>> diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
>> index af59791..9835117 100644
>> --- a/utils/gssd/Makefile.am
>> +++ b/utils/gssd/Makefile.am
>> @@ -1,10 +1,17 @@
>>  ## Process this file with automake to produce Makefile.in
>>  
>> -man8_MANS	= gssd.man svcgssd.man
>> +man8_MANS	= gssd.man
>> +if CONFIG_SVCGSS
>> +man8_MANS	+= svcgssd.man
>> +endif
>>  
>>  RPCPREFIX	= rpc.
>>  KPREFIX		= @kprefix@
>> -sbin_PREFIXED	= gssd svcgssd
>> +sbin_PREFIXED	= gssd
>> +if CONFIG_SVCGSS
>> +sbin_PREFIXED	+= svcgssd
>> +endif
>> +
>>  sbin_PROGRAMS	= $(sbin_PREFIXED)
>>  
>>  EXTRA_DIST = \
>> -- 
>> 1.9.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
