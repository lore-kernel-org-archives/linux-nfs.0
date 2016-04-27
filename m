Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752216AbcD0PXh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 11:23:37 -0400
Subject: Re: [PATCH v3 1/3] gssd: use pthreads to handle upcalls
To: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
References: <1461603513-67523-1-git-send-email-kolga@netapp.com>
 <1461603513-67523-2-git-send-email-kolga@netapp.com>
 <5720D2BA.5010400@RedHat.com>
 <59AF3631-819C-42E5-AB0D-3483590E279D@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <5720D977.10008@RedHat.com>
Date: Wed, 27 Apr 2016 11:23:35 -0400
MIME-Version: 1.0
In-Reply-To: <59AF3631-819C-42E5-AB0D-3483590E279D@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/27/2016 11:16 AM, Kornievskaia, Olga wrote:
> 
>> On Apr 27, 2016, at 10:54 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>
>>
>> On 04/25/2016 12:58 PM, Olga Kornievskaia wrote:
>>> Currently, to persevere global data over multiple mounts,
>>> the root process does not fork when handling an upcall.
>>> Instead on not-forking create a pthread to handle the
>>> upcall since global data can be shared among threads.
>>>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>> ---
>>> aclocal/libpthread.m4  | 13 +++++++++++++
>>> configure.ac           |  3 +++
>>> utils/gssd/Makefile.am |  3 ++-
>>> utils/gssd/gssd.c      | 45 ++++++++++++++++++++++++++++++++++++++++-----
>>> utils/gssd/gssd.h      |  5 +++++
>>> utils/gssd/gssd_proc.c | 49 ++++++++++++++++++-------------------------------
>>> utils/gssd/krb5_util.c |  3 +++
>>> 7 files changed, 84 insertions(+), 37 deletions(-)
>>> create mode 100644 aclocal/libpthread.m4
>>>
>>> diff --git a/aclocal/libpthread.m4 b/aclocal/libpthread.m4
>>> new file mode 100644
>>> index 0000000..e87d2a0
>>> --- /dev/null
>>> +++ b/aclocal/libpthread.m4
>>> @@ -0,0 +1,13 @@
>>> +dnl Checks for pthreads library and headers
>>> +dnl
>>> +AC_DEFUN([AC_LIBPTHREAD], [
>>> +
>>> +    dnl Check for library, but do not add -lpthreads to LIBS
>>> +    AC_CHECK_LIB([pthread], [pthread_create], [LIBPTHREAD=-lpthread],
>>> +                 [AC_MSG_ERROR([libpthread not found.])])
>>> +  AC_SUBST(LIBPTHREAD)
>>> +
>>> +  AC_CHECK_HEADERS([pthread.h], ,
>>> +                   [AC_MSG_ERROR([libpthread headers not found.])])
>>> +
>>> +])dnl
>>> diff --git a/configure.ac b/configure.ac
>>> index 25d2ba4..e0ecd61 100644
>>> --- a/configure.ac
>>> +++ b/configure.ac
>>> @@ -385,6 +385,9 @@ if test "$enable_gss" = yes; then
>>>   dnl Invoked after AC_KERBEROS_V5; AC_LIBRPCSECGSS needs to have KRBLIBS set
>>>   AC_LIBRPCSECGSS
>>>
>>> +  dnl Check for pthreads
>>> +  AC_LIBPTHREAD
>>> +
>>>   dnl librpcsecgss already has a dependency on libgssapi,
>>>   dnl but we need to make sure we get the right version
>>>   if test "$enable_gss" = yes; then
>>> diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
>>> index cb040b3..3f5f59a 100644
>>> --- a/utils/gssd/Makefile.am
>>> +++ b/utils/gssd/Makefile.am
>>> @@ -49,7 +49,8 @@ gssd_LDADD = \
>>> 	$(RPCSECGSS_LIBS) \
>>> 	$(KRBLIBS) \
>>> 	$(GSSAPI_LIBS) \
>>> -	$(LIBTIRPC)
>>> +	$(LIBTIRPC) \
>>> +	$(LIBPTHREAD)
>>>
>>> gssd_LDFLAGS = \
>>> 	$(KRBLDFLAGS)
>>> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
>>> index e7cb07f..0b7ffca 100644
>>> --- a/utils/gssd/gssd.c
>>> +++ b/utils/gssd/gssd.c
>>> @@ -87,7 +87,9 @@ unsigned int  rpc_timeout = 5;
>>> char *preferred_realm = NULL;
>>> /* Avoid DNS reverse lookups on server names */
>>> static bool avoid_dns = true;
>>> -
>>> +int thread_started = false;
>>> +pthread_mutex_t pmutex = PTHREAD_MUTEX_INITIALIZER;
>>> +pthread_cond_t pcond = PTHREAD_COND_INITIALIZER;
>>>
>>> TAILQ_HEAD(topdir_list_head, topdir) topdir_list;
>>>
>>> @@ -361,20 +363,53 @@ gssd_destroy_client(struct clnt_info *clp)
>>>
>>> static void gssd_scan(void);
>>>
>>> +static void wait_for_child_and_detach(pthread_t th)
>>> +{
>>> +	pthread_mutex_lock(&pmutex);
>>> +	while (!thread_started)
>>> +		pthread_cond_wait(&pcond, &pmutex);
>>> +	thread_started = false;
>>> +	pthread_mutex_unlock(&pmutex);
>>> +	pthread_detach(th);
>>> +}
>> I was just looking at this... does it make more sense to
>> make these types of routines inline instead of allocating
>> stack space on every call... 
>>
>> With rpc.gssd, when running, is now involved every mount
>> (even sec=sys ones) so I'm wondering if inlining 4 new 
>> routines would buy us anything... 
>>
>> One down fall with inline routines it makes more
>> difficult to debug from gdb breakpoint point of view.
> 
> This doesn’t look like a function that we really 
> need to step into, does it? I think inlining it would be ok.
No it does not... inlining it is... 
> 
> I think the biggest saving would be to take the next step 
> and do the pool of threads that are pre-created (and thus 
> not taking time to be allocated for each upcall). Then we 
> need a way to make sure we cleanup any threads that might 
> be hanging for whatever reason.
This will be an excellent next step! 

steved.
