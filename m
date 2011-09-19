Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752021Ab1ISJv6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 05:51:58 -0400
Message-ID: <4E7710B7.7070804@RedHat.com>
Date: Mon, 19 Sep 2011 05:51:51 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] configure.ac: Added server 4.1 support configuration
 option
References: <1316272622-4894-1-git-send-email-steved@redhat.com> <20110917183645.GA24278@fieldses.org>
In-Reply-To: <20110917183645.GA24278@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/17/2011 02:36 PM, J. Bruce Fields wrote:
> On Sat, Sep 17, 2011 at 11:17:01AM -0400, Steve Dickson wrote:
>> Separate the v4.1 support in the client and server
>> by creating the --enable-nfsdv4 configuration option.
> 
> I really dislike --enable-nfsdv4: people shouldn't have to rebuild
> nfs-utils in order to turn on server 4.1 support.  They should be able
> to do that at run time.
> 
> It makes sense for something like the block client, because there we
> actually have to decide whether to *build* something or not, and if
> someone knows they're never going to use that daemon, maybe they don't
> want to bother building and installing it.
> 
> For server 4.1 support, we're making them rebuild just to change the
> value of a single constant.  Why?
If I remember correctly, that's the way you wanted... We disabled 
4.1 server supported this way, because the code did not conform to 
the RFC. This was done back in Fed 2010.

All this patch is doing is reorganizing things so there is a
configuration option to enable/disable the 4.1 client.   

Now, I agree. Enabling/disabling the 4.1 server in a more 
dynamic way would be good... Is the code ready for that?
Should this constraint be remove completely? 

steved.
> 
> --b.
> 
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  configure.ac              |   19 ++++++++++++++++---
>>  support/include/nfs/nfs.h |    2 +-
>>  2 files changed, 17 insertions(+), 4 deletions(-)
>>
>> diff --git a/configure.ac b/configure.ac
>> index 1a28f8a..18a735d 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -75,17 +75,30 @@ AC_ARG_ENABLE(nfsv4,
>>  
>>  AC_ARG_ENABLE(nfsv41,
>>  	[AC_HELP_STRING([--enable-nfsv41],
>> -                        [enable support for NFSv41 @<:@default=no@:>@])],
>> +                        [enable for NFS v4.1 client support @<:@default=yes@:>@])],
>>  	enable_nfsv41=$enableval,
>> -	enable_nfsv41=no)
>> +	enable_nfsv41=yes)
>>  	if test "$enable_nfsv41" = yes; then
>> -		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv41 support compiled in])
>> +		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv4.1 client support compiled in])
>>  	else
>>  		enable_nfsv41=
>>  	fi
>>  	AC_SUBST(enable_nfsv41)
>>  	AM_CONDITIONAL(CONFIG_NFSV41, [test "$enable_nfsv41" = "yes"])
>>  
>> +AC_ARG_ENABLE(nfsvd41,
>> +	[AC_HELP_STRING([--enable-nfsdv41],
>> +                        [enable for NFS v4.1 server support @<:@default=no@:>@])],
>> +	enable_nfsdv41=$enableval,
>> +	enable_nfsvd41=no)
>> +	if test "$enable_nfsdv41" = yes; then
>> +		AC_DEFINE(NFSD41_SUPPORTED, 1, [Define this if you want NFSv4.1 server support compiled in])
>> +	else
>> +		enable_nfsdv41=
>> +	fi
>> +	AC_SUBST(enable_nfsdv41)
>> +	AM_CONDITIONAL(CONFIG_NFSDV41, [test "$enable_nfsdv41" = "yes"])
>> +
>>  AC_ARG_ENABLE(gss,
>>  	[AC_HELP_STRING([--enable-gss],
>>                          [enable support for rpcsec_gss @<:@default=yes@:>@])],
>> diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
>> index c939d78..d06ac1f 100644
>> --- a/support/include/nfs/nfs.h
>> +++ b/support/include/nfs/nfs.h
>> @@ -16,7 +16,7 @@
>>  #define NFSD_MAXVERS 4
>>  
>>  #define NFSD_MINMINORVERS4 1
>> -#ifdef  NFS41_SUPPORTED
>> +#ifdef  NFSD41_SUPPORTED
>>  #define NFSD_MAXMINORVERS4 1
>>  #else
>>  #define NFSD_MAXMINORVERS4 0
>> -- 
>> 1.7.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
