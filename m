Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48408 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750849AbdGUQ3O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 12:29:14 -0400
Subject: Re: [PATCH 08/11] network.c: removed some warnings
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170719205354.10006-1-steved@redhat.com>
 <20170719205354.10006-9-steved@redhat.com>
 <20170720183759.GC19909@fieldses.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <d9540498-7325-e0b3-870f-47ee709a69d2@RedHat.com>
Date: Fri, 21 Jul 2017 12:29:12 -0400
MIME-Version: 1.0
In-Reply-To: <20170720183759.GC19909@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/20/2017 02:37 PM, J. Bruce Fields wrote:
> On Wed, Jul 19, 2017 at 04:53:51PM -0400, Steve Dickson wrote:
>> network.c:1234:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
>> network.c:1382:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
>> network.c:1477:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
>> network.c:1508:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
>> network.c:1574:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
> 
> Looks like after this an out-of-range port number will be treated as an
> unspecified port rather than returning an error.  That sounds wrong.
> 
> I didn't check the others.
> 
> All of these "break" statements added without any explanation are making
> me nervous.
Yeah you are right... Boy there are some subtle things going there... 

Thanks for the review and cycles! 

steved.

> 
> --b.
> 
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/mount/network.c | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>> index 281e935..19f14e5 100644
>> --- a/utils/mount/network.c
>> +++ b/utils/mount/network.c
>> @@ -1235,6 +1235,7 @@ nfs_nfs_program(struct mount_options *options, unsigned long *program)
>>  			*program = tmp;
>>  			return 1;
>>  		}
>> +		break;
>>  	case PO_BAD_VALUE:
>>  		nfs_error(_("%s: invalid value for 'nfsprog=' option"),
>>  				progname);
>> @@ -1383,6 +1384,7 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
>>  			*port = tmp;
>>  			return 1;
>>  		}
>> +		break;
>>  	case PO_BAD_VALUE:
>>  		nfs_error(_("%s: invalid value for 'port=' option"),
>>  				progname);
>> @@ -1478,6 +1480,7 @@ nfs_mount_program(struct mount_options *options, unsigned long *program)
>>  			*program = tmp;
>>  			return 1;
>>  		}
>> +		break;
>>  	case PO_BAD_VALUE:
>>  		nfs_error(_("%s: invalid value for 'mountprog=' option"),
>>  				progname);
>> @@ -1509,6 +1512,7 @@ nfs_mount_version(struct mount_options *options, unsigned long *version)
>>  			*version = tmp;
>>  			return 1;
>>  		}
>> +		break;
>>  	case PO_BAD_VALUE:
>>  		nfs_error(_("%s: invalid value for 'mountvers=' option"),
>>  				progname);
>> @@ -1575,6 +1579,7 @@ nfs_mount_port(struct mount_options *options, unsigned long *port)
>>  			*port = tmp;
>>  			return 1;
>>  		}
>> +		break;
>>  	case PO_BAD_VALUE:
>>  		nfs_error(_("%s: invalid value for 'mountport=' option"),
>>  				progname);
>> -- 
>> 2.13.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
