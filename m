From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Only warn on unrecognized mount options
Date: Fri, 11 Apr 2008 16:13:29 -0400
Message-ID: <47FFC669.80702@oracle.com>
References: <20080411200249.28007.12509.stgit@manray.1015granger.net> <47FFC50C.7020505@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060102010603030603030608"
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:32511 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757900AbYDKUOi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Apr 2008 16:14:38 -0400
In-Reply-To: <47FFC50C.7020505@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060102010603030603030608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Peter Staubach wrote:
> Chuck Lever wrote:
>> To provide compatibility with automounters who use a common set of mount
>> options for all file systems, change the NFS in-kernel mount option 
>> parser
>> to ignore mount options it doesn't recognize.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> Yet another NFS mount patch!  Build tested only.  Comments?
>>
>>  fs/nfs/super.c |    7 ++-----
>>  1 files changed, 2 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index f921902..a7201f0 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -1044,7 +1044,8 @@ static int nfs_parse_mount_options(char *raw,
>>              break;
>>  
>>          default:
>> -            goto out_unknown;
>> +            printk(KERN_INFO "NFS: unrecognized mount option '%s'"
>> +                    " ignored\n", p);
>>          }
>>      }
>>  
>> @@ -1070,10 +1071,6 @@ out_unrec_xprt:
>>  out_unrec_sec:
>>      printk(KERN_INFO "NFS: unrecognized security flavor\n");
>>      return 0;
>> -
>> -out_unknown:
>> -    printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
>> -    return 0;
>>  }
>>  
>>  /*
> 
> This will potentially cause a very large number of messages to be
> printed in a valid deployment.  Do we really need the message?

I was wondering about that.

I left it in because it's useful to know when a valid mount option is 
misspelled.  In that case it might cause an important option (such as 
"noac") to be ignored.

--------------060102010603030603030608
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck_lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck_lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------060102010603030603030608--
