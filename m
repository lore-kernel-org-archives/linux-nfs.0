Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756462Ab1JMQe5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Oct 2011 12:34:57 -0400
Message-ID: <4E971329.3000007@RedHat.com>
Date: Thu, 13 Oct 2011 12:34:49 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Hamo <hamo.by@gmail.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: mount: really return from errno test
References: <CAO_0yfPgXJJSZNDYXHBSt45J0WQsh5EQVUs0nBN4wb+NoT6hAQ@mail.gmail.com> <40D1A40C-BE0C-4AE0-857D-05531615748E@oracle.com>
In-Reply-To: <40D1A40C-BE0C-4AE0-857D-05531615748E@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yeah... I believe its this one
   https://bugzilla.redhat.com/show_bug.cgi?id=744657

On 10/13/2011 10:53 AM, Chuck Lever wrote:
> What was the presenting problem?  Is there a bugzilla report I can look at?
> 
> On Oct 11, 2011, at 5:44 AM, Hamo wrote:
> 
>> We should only try next address family if we meet ECONNREFUSED or EHOSTUNREACH
>> for v4 or ECONNREFUSED or EOPNOTSUPP or EHOSTUNREACH for v3v2.
>> Before, only a break in swich can not make the program out of for loop.
>>
>> Signed-off-by: Yang Bai <hamo.by@gmail.com>
>> ---
>> utils/mount/stropts.c |    6 ++++--
>> 1 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index 314a806..4032bf3 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -665,9 +665,10 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
>> 		case EHOSTUNREACH:
>> 			continue;
>> 		default:
>> -			break;
>> +			goto out;
>> 		}
>> 	}
>> +out:
>> 	return ret;
>> }
>>
>> @@ -751,9 +752,10 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
>> 		case EHOSTUNREACH:
>> 			continue;
>> 		default:
>> -			break;
>> +			goto out;
>> 		}
>> 	}
>> +out:
>> 	return ret;
>> }
>>
>> -- 
>> 1.7.1
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
