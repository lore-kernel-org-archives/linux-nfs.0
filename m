From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] mount: silently fails when bad option values are
 given
Date: Thu, 03 Jun 2010 10:36:57 -0400
Message-ID: <4C07BE09.3060602@RedHat.com>
References: <1275570134-24864-1-git-send-email-steved@redhat.com> <1275570134-24864-2-git-send-email-steved@redhat.com> <4C07B669.2040300@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754708Ab0FCOhE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 10:37:04 -0400
In-Reply-To: <4C07B669.2040300@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/03/2010 10:04 AM, Chuck Lever wrote:
> On 06/ 3/10 09:02 AM, Steve Dickson wrote:
>> mount.nfs should not only fail when an invalid option values
>> are supplied (as it does), it should also print a diagnostic
>> message identifying the problem
>>
>> Signed-off-by: Steve Dickson<steved@redhat.com>
>> ---
>>   utils/mount/network.c   |   20 ++++++++++++++++++--
>>   utils/mount/nfsumount.c |    4 +---
>>   2 files changed, 19 insertions(+), 5 deletions(-)
>>
>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>> index c541257..d9903ed 100644
>> --- a/utils/mount/network.c
>> +++ b/utils/mount/network.c
>> @@ -1212,6 +1212,8 @@ nfs_nfs_program(struct mount_options *options,
>> unsigned long *program)
>>               return 1;
>>           }
> 
> Another missed fall-through.
I realized this.. but if tmp <= 0, then the given value is invalid
so an error message should be displayed.

> 
>>       case PO_BAD_VALUE:
>> +        nfs_error(_("%s: invalid value for 'nfsprog=' option"),
>> +                progname);
>>           return 0;
>>       }
>>
>> @@ -1251,9 +1253,12 @@ nfs_nfs_version(struct mount_options *options,
>> unsigned long *version)
>>               }
>>               return 0;
>>           case PO_NOT_FOUND:
>> -            nfs_error(_("%s: option parsing error\n"),
>> +            nfs_error(_("%s: parsing error on 'vers=' option\n"),
>>                       progname);
>> +            return 0;
>>           case PO_BAD_VALUE:
>> +            nfs_error(_("%s: invalid value for 'vers=' option"),
>> +                    progname);
>>               return 0;
>>           }
> 
> What I meant before is that, with this new code, this error diagnostic
> is displayed for "vers=booger" but not for "vers=12".  I think it should
> be displayed in both cases.
ah... This is not only routine where PO_FOUND is returned but the
value is invalid...  

> 
>>       case 4: /* nfsvers */
>> @@ -1265,9 +1270,12 @@ nfs_nfs_version(struct mount_options *options,
>> unsigned long *version)
>>               }
>>               return 0;
>>           case PO_NOT_FOUND:
>> -            nfs_error(_("%s: option parsing error\n"),
>> +            nfs_error(_("%s: parsing error on 'nfsvers=' option\n"),
>>                       progname);
>> +            return 0;
>>           case PO_BAD_VALUE:
>> +            nfs_error(_("%s: invalid value for 'nfsvers=' option"),
>> +                    progname);
>>               return 0;
>>           }
>>       }
>> @@ -1336,6 +1344,8 @@ nfs_nfs_port(struct mount_options *options,
>> unsigned long *port)
>>               return 1;
>>           }
> 
> Another missed fall-through.
again known... 

> 
>>       case PO_BAD_VALUE:
>> +        nfs_error(_("%s: invalid value for 'port=' option"),
>> +                progname);
>>           return 0;
>>       }
> 
> And here, an error diagnostic is displayed for "port=crikey" but not for
> "port=-17".
> 
>> @@ -1423,6 +1433,8 @@ nfs_mount_program(struct mount_options *options,
>> unsigned long *program)
>>               return 1;
>>           }
> 
> Another missed fall-through.
Same as above... 

> 
>>       case PO_BAD_VALUE:
>> +        nfs_error(_("%s: invalid value for 'mountprog=' option"),
>> +                progname);
>>           return 0;
>>       }
>>
>> @@ -1452,6 +1464,8 @@ nfs_mount_version(struct mount_options *options,
>> unsigned long *version)
>>               return 1;
>>           }
> 
> Ditto.
Ditto... :-)

> 
>>       case PO_BAD_VALUE:
>> +        nfs_error(_("%s: invalid value for 'mountvers=' option"),
>> +                progname);
>>           return 0;
>>       }
>>
>> @@ -1510,6 +1524,8 @@ nfs_mount_port(struct mount_options *options,
>> unsigned long *port)
>>               return 1;
>>           }
> 
> Ditto.
Double Ditto.. :-)

steved.


> 
>>       case PO_BAD_VALUE:
>> +        nfs_error(_("%s: invalid value for 'mountport=' option"),
>> +                progname);
>>           return 0;
>>       }
>>
>> diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
>> index 9d798a2..1514340 100644
>> --- a/utils/mount/nfsumount.c
>> +++ b/utils/mount/nfsumount.c
>> @@ -179,10 +179,8 @@ static int nfs_umount_do_umnt(struct
>> mount_options *options,
>>       struct pmap nfs_pmap, mnt_pmap;
>>       sa_family_t family;
>>
>> -    if (!nfs_options2pmap(options,&nfs_pmap,&mnt_pmap)) {
>> -        nfs_error(_("%s: bad mount options"), progname);
>> +    if (!nfs_options2pmap(options,&nfs_pmap,&mnt_pmap))
>>           return EX_FAIL;
>> -    }
>>
>>       /* Skip UMNT call for vers=4 mounts */
>>       if (nfs_pmap.pm_vers == 4)
> 
