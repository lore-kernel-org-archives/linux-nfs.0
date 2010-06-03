From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] mount.nfs: silently fails when the network protocol
 is not found
Date: Thu, 03 Jun 2010 12:42:51 -0400
Message-ID: <4C07DB8B.4040702@RedHat.com>
References: <1275570134-24864-1-git-send-email-steved@redhat.com> <1275570134-24864-3-git-send-email-steved@redhat.com> <4C07B8A6.3020803@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755896Ab0FCRey (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 13:34:54 -0400
In-Reply-To: <4C07B8A6.3020803@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/03/2010 10:13 AM, Chuck Lever wrote:
> On 06/ 3/10 09:02 AM, Steve Dickson wrote:
>> mount.nfs should display some type of error diagnostics when
>> the network protocol can not be determined.
>>
>> Signed-off-by: Steve Dickson<steved@redhat.com>
>> ---
>>   utils/mount/network.c |   19 ++++++++++++++++---
>>   utils/mount/stropts.c |   16 +++++++++++-----
>>   2 files changed, 27 insertions(+), 8 deletions(-)
>>
>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>> index d9903ed..ffb18ab 100644
>> --- a/utils/mount/network.c
>> +++ b/utils/mount/network.c
>> @@ -1311,6 +1311,8 @@ nfs_nfs_protocol(struct mount_options *options,
>> unsigned long *protocol)
>>           if (option != NULL) {
>>               if (!nfs_get_proto(option,&family, protocol)) {
>>                   errno = EPROTONOSUPPORT;
>> +                nfs_error(_("%s: Failed to find '%s' protocol"),
>> +                    progname, option);
> 
> Set the errno _after_ calling nfs_error(), which could set it to
> something else.  nfs_error() does call C library functions which may
> alter errno, after all.
point.

> 
>>                   return 0;
>>               }
>>               return 1;
>> @@ -1399,8 +1401,13 @@ int nfs_nfs_proto_family(struct mount_options
>> *options,
>>       case 2: /* proto */
>>           option = po_get(options, "proto");
>>           if (option != NULL&&
>> -            !nfs_get_proto(option,&tmp_family,&protocol))
>> -            goto out_err;
>> +            !nfs_get_proto(option,&tmp_family,&protocol)) {
>> +
>> +            nfs_error(_("%s: Failed to find '%s' protocol"),
>> +                progname, option);
>> +            errno = EPROTONOSUPPORT;
>> +            return 0;
>> +        }
>>       }
>>
>>       if (!nfs_verify_family(tmp_family))
>> @@ -1492,6 +1499,8 @@ nfs_mount_protocol(struct mount_options
>> *options, unsigned long *protocol)
>>       if (option != NULL) {
>>           if (!nfs_get_proto(option,&family, protocol)) {
>>               errno = EPROTONOSUPPORT;
>> +            nfs_error(_("%s: Failed to find '%s' protocol"),
>> +                progname, option);
> 
> Ditto.
> 
>>               return 0;
>>           }
>>           return 1;
>> @@ -1551,8 +1560,12 @@ int nfs_mount_proto_family(struct mount_options
>> *options,
>>
>>       option = po_get(options, "mountproto");
>>       if (option != NULL) {
>> -        if (!nfs_get_proto(option,&tmp_family,&protocol))
>> +        if (!nfs_get_proto(option,&tmp_family,&protocol)) {
>> +            nfs_error(_("%s: Failed to find '%s' protocol"),
>> +                progname, option);
>> +            errno = EPROTONOSUPPORT;
>>               goto out_err;
>> +        }
> 
> Does out_err also clobber errno here as well?
Ah... I thought I fixed that...

> 
>>           if (!nfs_verify_family(tmp_family))
>>               goto out_err;
>>           *family = tmp_family;
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index 98557d2..0241400 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -538,7 +538,10 @@ nfs_rewrite_pmap_mount_options(struct
>> mount_options *options)
>>
>>       if (!nfs_construct_new_options(options, nfs_saddr,&nfs_pmap,
>>                       mnt_saddr,&mnt_pmap)) {
>> -        errno = EINVAL;
>> +        if (rpc_createerr.cf_stat == RPC_UNKNOWNPROTO)
>> +            errno = EPROTONOSUPPORT;
>> +        else
>> +            errno = EINVAL;
>>           return 0;
>>       }
>>
>> @@ -586,18 +589,21 @@ static int nfs_do_mount_v3v2(struct
>> nfsmount_info *mi,
>>           errno = ENOMEM;
>>           return result;
>>       }
>> -
>> +    errno = 0;
>>       if (!nfs_append_addr_option(sap, salen, options)) {
>> -        errno = EINVAL;
>> +        if (errno == 0)
>> +            errno = EINVAL;
>>           goto out_fail;
> 
> What I meant before is that the errno should really be set right where
> the error is detected, not long afterwards in some other part of the code.
> 
> Currently it looks like nfs_append_addr_option() sets the errno
> sometimes, and sometimes it doesn't and the errno is set here.  I think
> the code would make more sense overall if the errno was always
> appropriately set by the time nfs_append_addr_option() returns.
> 
> Likewise for nfs_construct_new_options() above.
> 
>>       }
>>
>>       if (!nfs_fix_mounthost_option(options, mi->hostname)) {
>> -        errno = EINVAL;
>> +        if (errno == 0)
>> +            errno = EINVAL;
>>           goto out_fail;
>>       }
>>       if (!mi->fake&&  !nfs_verify_lock_option(options)) {
>> -        errno = EINVAL;
>> +        if (errno == 0)
>> +            errno = EINVAL;
>>           goto out_fail;
>>       }
>>
> 
> Likewise for these two.
Understood... Please remember the original patch was for 
when the network protocol can not be found... While I agree
with the need of the clean, that is a bit out of the scope
the original patch... 

I'm all for going back and doing this clean up... but a this particular 
moment I need to fix this bug and move on.. 

steved.
