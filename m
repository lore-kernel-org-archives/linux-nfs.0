Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755147Ab1ISR4U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 13:56:20 -0400
Message-ID: <4E778241.3080605@RedHat.com>
Date: Mon, 19 Sep 2011 13:56:17 -0400
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
After further review... I kinda like the idea of decoupling statd's
state directory from /var/lib/nfs which basically what the 
statdpath.patch 

> 
> If we do what you're suggesting above, we'll need a transition scheme
> for Fedora and RHEL, and a way to deal with making statd run as the
> proper user. I don't think we really want to go to that much effort for
> statd...
> 
Not if we take the following patch... ;-)


What do you guys think of something like:

commit da6eebe9b01ac132185364efe30b4ba54fc4134c
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Sep 19 11:37:36 2011 -0400

    statd: Decouple statd's state directory from the NFS state directory
    
    To allow greater flexibly to where the state for
    statd is written, this patch introduces the NSM_STATD_PATH
    definition that can be defined at compile time with
    the --with-statdpath flag.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/configure.ac b/configure.ac
index 1a28f8a..6558672 100644
--- a/configure.ac
+++ b/configure.ac
@@ -22,6 +22,14 @@ AC_ARG_WITH(statedir,
 	statedir=$withval,
 	statedir=/var/lib/nfs)
 	AC_SUBST(statedir)
+AC_ARG_WITH(statdpath,
+	[AC_HELP_STRING([--with-statdpath=/foo],
+		[Causes statd put it's state file in /foo instead of statedir]
+	)],
+	statdpath=$withval,
+	statdpath=""
+	)
+	AC_SUBST(statdpath)
 AC_ARG_WITH(statduser,
 	[AC_HELP_STRING([--with-statduser=rpcuser],
                         [statd to run under @<:@rpcuser or nobody@:>@]
@@ -386,6 +394,9 @@ dnl *************************************************************
 dnl Export some path names to config.h
 dnl *************************************************************
 AC_DEFINE_UNQUOTED(NFS_STATEDIR, "$statedir", [This defines the location of the NFS state files. Warning: this must match definitions in config.mk!])
+if test "$statdpath" != ""; then
+		AC_DEFINE_UNQUOTED(NSM_STATD_PATH, "$statdpath", [Define this if you what statd file placed in somewhere other than NFS_STATEDIR])
+fi
 
 if test "x$cross_compiling" = "xno"; then
 	CFLAGS_FOR_BUILD=${CFLAGS_FOR_BUILD-"$CFLAGS"}
diff --git a/support/nsm/file.c b/support/nsm/file.c
index a12c753..2427a6c 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -95,12 +95,13 @@
 #define NSM_KERNEL_STATE_FILE	"/proc/sys/fs/nfs/nsm_local_state"
 
 /*
- * Some distributions place statd's files in a subdirectory
+ * Allow different places for statd's files
  */
-#define NSM_PATH_EXTENSION
-/* #define NSM_PATH_EXTENSION	"/statd" */
-
-#define NSM_DEFAULT_STATEDIR		NFS_STATEDIR NSM_PATH_EXTENSION
+#ifdef NSM_STATD_PATH
+#define NSM_DEFAULT_STATEDIR		NSM_STATD_PATH
+#else
+#define NSM_DEFAULT_STATEDIR		NFS_STATEDIR 
+#endif
 
 static char nsm_base_dirname[PATH_MAX] = NSM_DEFAULT_STATEDIR;
 
