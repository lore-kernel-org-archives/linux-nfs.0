Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757281Ab0HDNug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 09:50:36 -0400
Message-ID: <4C597028.9040404@RedHat.com>
Date: Wed, 04 Aug 2010 09:50:32 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 08/24] Removed warnings from mountd.c
References: <1279669057-17509-1-git-send-email-steved@redhat.com> <1279669057-17509-9-git-send-email-steved@redhat.com> <4C472D28.6050608@oracle.com>
In-Reply-To: <4C472D28.6050608@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 07/21/2010 01:23 PM, Chuck Lever wrote:
> Hi Steve-
> 
>>
>> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
>> index 6571454..43aec11 100644
>> --- a/utils/mountd/mountd.c
>> +++ b/utils/mountd/mountd.c
>> @@ -194,6 +194,9 @@ sig_hup (int sig)
>>   bool_t
>>   mount_null_1_svc(struct svc_req *rqstp, void *argp, void *resp)
>>   {
>> +    xlog(D_CALL, "MNT1(%s) null: rqstp %p argp %p resp %p",
>> +        rqstp, argp, resp);
>> +
>>       return 1;
>>   }
>>
> 
> I have to agree with Bruce: adding xlog() calls here is the wrong thing
> to do.  Instead, use
> 
>    __attribute__((unused))
> 
> for the unused parameters.
Boy... using those really make the code look ugly...
bool_t
mount_null_1_svc(
    __attribute__((unused))struct svc_req *rqstp , 
    __attribute__((unused))void *argp, 
    __attribute__((unused))void *resp)
{
    return 1;
}
So ugly up the code verses adding a bit more debugging... I must
say I'm leaning toward the latter... 

> 
>>       if (!(exp = auth_authenticate("unmount", sin, p))) {
>>           return 1;
>> @@ -247,10 +253,15 @@ mount_umnt_1_svc(struct svc_req *rqstp, dirpath
>> *argp, void *resp)
>>   bool_t
>>   mount_umntall_1_svc(struct svc_req *rqstp, void *argp, void *resp)
>>   {
>> +    struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
>> +
>> +    xlog(D_CALL, "UMNT1(%s) unmountall: argp %s resp %p",
>> +        inet_ntoa(sin->sin_addr), argp, resp);
>> +
>>       /* Reload /etc/xtab if necessary */
>>       auth_reload();
>>
>> -    mountlist_del_all(nfs_getrpccaller_in(rqstp->rq_xprt));
>> +    mountlist_del_all(sin);
> 
> You couldn't wait until the rest of my IPv6 mountd patches are
> integrated?  I address a lot of these problems in those patches, and now
> I'm going to have to rebase all of that work.  What's the rush?
No rush.. I just wanted to clean things up... 

steved.
