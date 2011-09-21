From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/1 v2] statd: Decouple statd's state directory from the
 NFS state directory
Date: Wed, 21 Sep 2011 15:39:31 -0400
Message-ID: <4E7A3D73.4080807@RedHat.com>
References: <1316537869-2257-1-git-send-email-steved@redhat.com> <E7472A90-76BB-47E3-B252-897291F88803@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784Ab1IUTje (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 15:39:34 -0400
In-Reply-To: <E7472A90-76BB-47E3-B252-897291F88803@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/20/2011 01:05 PM, Chuck Lever wrote:
> 
> On Sep 20, 2011, at 12:57 PM, Steve Dickson wrote:
> 
>> To allow greater flexibility to where statd's state is kept,
>> statd's state path can now be decoupled from the normal
>> NFS state directory.
>>
>> In configure.ac, the NSM_STATD_PATH definition will now define
> 
> In the description:
>   s/NSM_STATD_PATH/NSM_DEFAULT_STATEDIR/
> 
> Otherwise,
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Committed with the above change... 

steved.
> 
>> the path to where the state information is kept.  The default
>> value, /var/lib/nfs, can be redefined with the --with-statdpath
>> flag.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> configure.ac       |    9 +++++++++
>> support/nsm/file.c |    8 --------
>> 2 files changed, 9 insertions(+), 8 deletions(-)
>>
>> diff --git a/configure.ac b/configure.ac
>> index b5934c4..500172b 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -23,6 +23,14 @@ AC_ARG_WITH(statedir,
>> 	statedir=$withval,
>> 	statedir=/var/lib/nfs)
>> 	AC_SUBST(statedir)
>> +AC_ARG_WITH(statdpath,
>> +	[AC_HELP_STRING([--with-statdpath=/foo @<:@default=/var/lib/nfs@:>@],
>> +		[define statd's state dir as /foo instead of the NFS statedir]
>> +	)],
>> +	statdpath=$withval,
>> +	statdpath=$statedir
>> +	)
>> +	AC_SUBST(statdpath)
>> AC_ARG_WITH(statduser,
>> 	[AC_HELP_STRING([--with-statduser=rpcuser],
>>                         [statd to run under @<:@rpcuser or nobody@:>@]
>> @@ -387,6 +395,7 @@ dnl *************************************************************
>> dnl Export some path names to config.h
>> dnl *************************************************************
>> AC_DEFINE_UNQUOTED(NFS_STATEDIR, "$statedir", [This defines the location of the NFS state files. Warning: this must match definitions in config.mk!])
>> +AC_DEFINE_UNQUOTED(NSM_DEFAULT_STATEDIR, "$statdpath", [Define this to the pathname where statd keeps its state file])
>>
>> if test "x$cross_compiling" = "xno"; then
>> 	CFLAGS_FOR_BUILD=${CFLAGS_FOR_BUILD-"$CFLAGS"}
>> diff --git a/support/nsm/file.c b/support/nsm/file.c
>> index a12c753..5dd52c1 100644
>> --- a/support/nsm/file.c
>> +++ b/support/nsm/file.c
>> @@ -94,14 +94,6 @@
>>
>> #define NSM_KERNEL_STATE_FILE	"/proc/sys/fs/nfs/nsm_local_state"
>>
>> -/*
>> - * Some distributions place statd's files in a subdirectory
>> - */
>> -#define NSM_PATH_EXTENSION
>> -/* #define NSM_PATH_EXTENSION	"/statd" */
>> -
>> -#define NSM_DEFAULT_STATEDIR		NFS_STATEDIR NSM_PATH_EXTENSION
>> -
>> static char nsm_base_dirname[PATH_MAX] = NSM_DEFAULT_STATEDIR;
>>
>> #define NSM_MONITOR_DIR	"sm"
>> -- 
>> 1.7.6.2
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
