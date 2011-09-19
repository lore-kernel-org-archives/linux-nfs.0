Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56224 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755087Ab1ISKqi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 06:46:38 -0400
Message-ID: <4E771D8A.8020400@RedHat.com>
Date: Mon, 19 Sep 2011 06:46:34 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/8] configure.ac: Add --with-statd-extension configure
 option
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net>	<20110912220623.10854.69881.stgit@matisse.1015granger.net>	<4E74927D.2070600@RedHat.com> <20110918074925.5b620286@tlielax.poochiereds.net>
In-Reply-To: <20110918074925.5b620286@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/18/2011 07:49 AM, Jeff Layton wrote:
> On Sat, 17 Sep 2011 08:28:45 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 09/12/2011 06:06 PM, Chuck Lever wrote:
>>> Currently some distributions patch nfs-utils to put NSM state in a
>>> subdirectory of /var/lib/nfs.  Make this a configure option instead.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>>  configure.ac       |    8 ++++++++
>>>  support/nsm/file.c |    9 +--------
>>>  2 files changed, 9 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/configure.ac b/configure.ac
>>> index 461a96a..ba704e2 100644
>>> --- a/configure.ac
>>> +++ b/configure.ac
>>> @@ -23,6 +23,14 @@ AC_ARG_WITH(statedir,
>>>  	statedir=$withval,
>>>  	statedir=/var/lib/nfs)
>>>  	AC_SUBST(statedir)
>>> +AC_ARG_WITH(statd-extension,
>>> +	[AC_HELP_STRING([--with-statd-extension=foo],
>>> +                        [Put NSM state in subdir foo of statedir])],
>>> +	statdext=$withval,
>>> +	statdext="")
>>> +	AC_SUBST(statdext)
>>> +	AC_DEFINE_UNQUOTED(NSM_PATH_EXTENSION, "$statdext",
>>> +			   [This defines the statedir subdirectory containing NSM state files.])
>>>  AC_ARG_WITH(statduser,
>>>  	[AC_HELP_STRING([--with-statduser=rpcuser],
>>>                          [statd to run under @<:@rpcuser or nobody@:>@]
>>> diff --git a/support/nsm/file.c b/support/nsm/file.c
>>> index a12c753..b4a5af1 100644
>>> --- a/support/nsm/file.c
>>> +++ b/support/nsm/file.c
>>> @@ -93,14 +93,7 @@
>>>  #define LINELEN		(RPCARGSLEN + SM_PRIV_SIZE * 2 + 1)
>>>  
>>>  #define NSM_KERNEL_STATE_FILE	"/proc/sys/fs/nfs/nsm_local_state"
>>> -
>>> -/*
>>> - * Some distributions place statd's files in a subdirectory
>>> - */
>>> -#define NSM_PATH_EXTENSION
>>> -/* #define NSM_PATH_EXTENSION	"/statd" */
>>> -
>>> -#define NSM_DEFAULT_STATEDIR		NFS_STATEDIR NSM_PATH_EXTENSION
>>> +#define NSM_DEFAULT_STATEDIR	NFS_STATEDIR "/" NSM_PATH_EXTENSION
>> Do we really need the NSM_PATH_EXTENSION define? Would it be more
>> straightforward to just have NFS_STATEDIR. Simplifying the code to:
>>
>> #ifndef NFS_STATEDIR 
>> #define NFS_STATEDIR "/var/lib/nfs"
>> #endif
>>
>> #define NSM_DEFAULT_STATEDIR		NFS_STATEDIR
>>
>> If there is no need for the extra NSM_PATH_EXTENSION define then 
>> we really don't want to create a configuration option for it.. IMHO..
>>
> 
> 
> IIRC, the statd directory is not standard between distributions. Some
> (like Fedora) put this dir in /var/lib/nfs/statd, and some just keep all
> of that in /var/lib/nfs.
> 
> The main reason for not making the NSM statedir be /var/lib/nfs is
> that statd defaults to running as the user that owns the statedir. We
> don't really want /var/lib/nfs owned by rpcuser since it contains other
> things that it shouldn't have access to if statd were compromised.
> 
> I think the idea here is to push this patch to mainline so we can stop
> carrying nfs-utils-1.2.2-statdpath.patch in the Fedora repo and turn it
> into an option that distros can use to put this in the location they
> prefer.
Ah... I did forget about that statdpath.patch, which basically
replaces the NSM_PATH_EXTENSION with a new NSM_STATD_PATH.

NSM_PATH_EXTENSION has been defined as NULL since Jan
of 2010 so it not be used by anybody. S would it be possible
to use the statdpath.patch patch instead, which would
mean no disto would have to change? ;-)

steved.

