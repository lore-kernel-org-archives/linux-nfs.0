Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:47400 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab0HDP6S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:58:18 -0400
Subject: Re: [PATCH 08/24] Removed warnings from mountd.c
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4C597028.9040404@RedHat.com>
Date: Wed, 4 Aug 2010 11:57:42 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <104DAA68-6BB8-43DF-BB8E-B76E5629DF52@oracle.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com> <1279669057-17509-9-git-send-email-steved@redhat.com> <4C472D28.6050608@oracle.com> <4C597028.9040404@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 4, 2010, at 9:50 AM, Steve Dickson wrote:

> 
> 
> On 07/21/2010 01:23 PM, Chuck Lever wrote:
>> Hi Steve-
>> 
>>> 
>>> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
>>> index 6571454..43aec11 100644
>>> --- a/utils/mountd/mountd.c
>>> +++ b/utils/mountd/mountd.c
>>> @@ -194,6 +194,9 @@ sig_hup (int sig)
>>>  bool_t
>>>  mount_null_1_svc(struct svc_req *rqstp, void *argp, void *resp)
>>>  {
>>> +    xlog(D_CALL, "MNT1(%s) null: rqstp %p argp %p resp %p",
>>> +        rqstp, argp, resp);
>>> +
>>>      return 1;
>>>  }
>>> 
>> 
>> I have to agree with Bruce: adding xlog() calls here is the wrong thing
>> to do.  Instead, use
>> 
>>   __attribute__((unused))
>> 
>> for the unused parameters.
> Boy... using those really make the code look ugly...
> bool_t
> mount_null_1_svc(
>    __attribute__((unused))struct svc_req *rqstp , 
>    __attribute__((unused))void *argp, 
>    __attribute__((unused))void *resp)
> {
>    return 1;
> }
> So ugly up the code verses adding a bit more debugging... I must
> say I'm leaning toward the latter... 

Aesthetics are in the eye of the beholder.  I don't find that at all difficult to read.  In fact, listing each parameter on a separate line is perhaps somewhat nicer that what we have here, and has a long history in C coding style.  If the look really bugs you, you can do what so many software projects before us have done:

  #define ARG_UNUSED __attribute__((unused))

or even:

  #define _unused_ __attribute__((unused))

I seem to recall that /usr/include/ldap.h has an example of this.  We may already have something like this in one of the nfs-utils headers.  There could also be shorter synonyms for __attribute__((unused)) available from the compiler.

Debugging messages in general are fine, but really there's no need to show the pointer addresses of the arguments and response for a NULL procedure, for example; that's entirely useless for debugging.  And, like the __attribute__ directive, adding noise in these messages can also be viewed as needless visual clutter (both in the source code, and in the system log, making it somewhat of a double sin).

A useful debugging message would display just the name of the procedure (eg. MNTPROC_NULL) and the client's IP address, and any arguments (NULL has none).  I'm not objecting to adding a debugging message here, but adding it solely for the purpose of quelling a compiler warning is, well, silly.  Let's fix the compiler warnings with an appropriate direct remedy, then consider introducing a debugging message on its own merit.

>>>      if (!(exp = auth_authenticate("unmount", sin, p))) {
>>>          return 1;
>>> @@ -247,10 +253,15 @@ mount_umnt_1_svc(struct svc_req *rqstp, dirpath
>>> *argp, void *resp)
>>>  bool_t
>>>  mount_umntall_1_svc(struct svc_req *rqstp, void *argp, void *resp)
>>>  {
>>> +    struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
>>> +
>>> +    xlog(D_CALL, "UMNT1(%s) unmountall: argp %s resp %p",
>>> +        inet_ntoa(sin->sin_addr), argp, resp);
>>> +
>>>      /* Reload /etc/xtab if necessary */
>>>      auth_reload();
>>> 
>>> -    mountlist_del_all(nfs_getrpccaller_in(rqstp->rq_xprt));
>>> +    mountlist_del_all(sin);
>> 
>> You couldn't wait until the rest of my IPv6 mountd patches are
>> integrated?  I address a lot of these problems in those patches, and now
>> I'm going to have to rebase all of that work.  What's the rush?
> No rush.. I just wanted to clean things up... 

Cleaning is good :-)  I've got many similar changes in my tree, and I'm committed to not introducing any new compiler warnings in my nfs-utils submissions.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



