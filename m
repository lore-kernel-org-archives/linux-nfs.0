Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60292 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754062AbdGUQU0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 12:20:26 -0400
Subject: Re: [PATCH 05/11] nfsd.c: removed a few warnings
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170719205354.10006-1-steved@redhat.com>
 <20170719205354.10006-6-steved@redhat.com>
 <20170720182824.GB19909@fieldses.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <686c124a-d4f8-836b-912d-32701421ad05@RedHat.com>
Date: Fri, 21 Jul 2017 12:20:25 -0400
MIME-Version: 1.0
In-Reply-To: <20170720182824.GB19909@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/20/2017 02:28 PM, J. Bruce Fields wrote:
> On Wed, Jul 19, 2017 at 04:53:48PM -0400, Steve Dickson wrote:
>> nfsd.c:187:8: warning: this statement may fall through [-Wimplicit-fallthrough=]
>> nfsd.c:213:8: warning: this statement may fall through [-Wimplicit-fallthrough=]nfsd.c:263:4: warning: this statement may fall through [-Wimplicit-fallthrough=]
> 
> Are you sure about this?  It looks to me like the fall through was
> intended in the -N4 and -V4 cases.
Wow... how un-obvious that! The -N4 actually does use the 
NFSCTL_VERUNSET() in the 3,2 case... Talk about in needed
of a comment! ;-)

steved.

> 
> --b.
> 
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/nfsd/nfsd.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
>> index 2b38249..1d35658 100644
>> --- a/utils/nfsd/nfsd.c
>> +++ b/utils/nfsd/nfsd.c
>> @@ -198,6 +198,7 @@ main(int argc, char **argv)
>>  					minorvers = 0;
>>  					minorversset = minormask;
>>  				}
>> +				break;
>>  			case 3:
>>  			case 2:
>>  				NFSCTL_VERUNSET(versbits, c);
>> @@ -220,6 +221,7 @@ main(int argc, char **argv)
>>  					NFSCTL_MINORSET(minorvers, i);
>>  				} else
>>  					minorvers = minorversset = minormask;
>> +				break;
>>  			case 3:
>>  			case 2:
>>  				NFSCTL_VERSET(versbits, c);
>> @@ -261,8 +263,9 @@ main(int argc, char **argv)
>>  			break;
>>  		default:
>>  			fprintf(stderr, "Invalid argument: '%c'\n", c);
>> +			/* FALLTHRU */
>>  		case 'h':
>> -			usage(progname);
>> +			usage(progname); /* usage does not return */
>>  		}
>>  	}
>>  
>> -- 
>> 2.13.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
