Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:49687 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab1ITQTf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 12:19:35 -0400
Subject: Re: [PATCH 3/8] configure.ac: Add --with-statd-extension configure option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E74927D.2070600@RedHat.com>
Date: Tue, 20 Sep 2011 12:14:16 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <4CEB3ADB-7D44-4E07-9115-69E8E8CF4E5D@oracle.com>
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net> <20110912220623.10854.69881.stgit@matisse.1015granger.net> <4E74927D.2070600@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 17, 2011, at 8:28 AM, Steve Dickson wrote:

> 
> 
> On 09/12/2011 06:06 PM, Chuck Lever wrote:
>> Currently some distributions patch nfs-utils to put NSM state in a
>> subdirectory of /var/lib/nfs.  Make this a configure option instead.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> configure.ac       |    8 ++++++++
>> support/nsm/file.c |    9 +--------
>> 2 files changed, 9 insertions(+), 8 deletions(-)
>> 
>> diff --git a/configure.ac b/configure.ac
>> index 461a96a..ba704e2 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -23,6 +23,14 @@ AC_ARG_WITH(statedir,
>> 	statedir=$withval,
>> 	statedir=/var/lib/nfs)
>> 	AC_SUBST(statedir)
>> +AC_ARG_WITH(statd-extension,
>> +	[AC_HELP_STRING([--with-statd-extension=foo],
>> +                        [Put NSM state in subdir foo of statedir])],
>> +	statdext=$withval,
>> +	statdext="")
>> +	AC_SUBST(statdext)
>> +	AC_DEFINE_UNQUOTED(NSM_PATH_EXTENSION, "$statdext",
>> +			   [This defines the statedir subdirectory containing NSM state files.])
>> AC_ARG_WITH(statduser,
>> 	[AC_HELP_STRING([--with-statduser=rpcuser],
>>                         [statd to run under @<:@rpcuser or nobody@:>@]
>> diff --git a/support/nsm/file.c b/support/nsm/file.c
>> index a12c753..b4a5af1 100644
>> --- a/support/nsm/file.c
>> +++ b/support/nsm/file.c
>> @@ -93,14 +93,7 @@
>> #define LINELEN		(RPCARGSLEN + SM_PRIV_SIZE * 2 + 1)
>> 
>> #define NSM_KERNEL_STATE_FILE	"/proc/sys/fs/nfs/nsm_local_state"
>> -
>> -/*
>> - * Some distributions place statd's files in a subdirectory
>> - */
>> -#define NSM_PATH_EXTENSION
>> -/* #define NSM_PATH_EXTENSION	"/statd" */
>> -
>> -#define NSM_DEFAULT_STATEDIR		NFS_STATEDIR NSM_PATH_EXTENSION
>> +#define NSM_DEFAULT_STATEDIR	NFS_STATEDIR "/" NSM_PATH_EXTENSION
> Do we really need the NSM_PATH_EXTENSION define? Would it be more
> straightforward to just have NFS_STATEDIR. Simplifying the code to:
> 
> #ifndef NFS_STATEDIR 
> #define NFS_STATEDIR "/var/lib/nfs"
> #endif
> 
> #define NSM_DEFAULT_STATEDIR		NFS_STATEDIR
> 
> If there is no need for the extra NSM_PATH_EXTENSION define then 
> we really don't want to create a configuration option for it.. IMHO..

RH likes to put statd files in /var/lib/nfs/statd, but everyone else puts them in /var/lib/nfs. So NSM_DEFAULT_STATEDIR is not the same as NFS_STATEDIR on RH distributions.

I'm caught by this every time I want to test upstream nfs-utils on my Fedora systems.  I have to maintain a separate patch, remember to apply it before testing, and then remember to remove it before pushing my patches to git.linux-nfs.org.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




