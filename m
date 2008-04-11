From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] NFS: Only warn on unrecognized mount options
Date: Fri, 11 Apr 2008 16:23:11 -0400
Message-ID: <47FFC8AF.8020009@redhat.com>
References: <20080411200249.28007.12509.stgit@manray.1015granger.net> <47FFC50C.7020505@redhat.com> <47FFC669.80702@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759307AbYDKUXw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Apr 2008 16:23:52 -0400
In-Reply-To: <47FFC669.80702@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> Peter Staubach wrote:
>> Chuck Lever wrote:
>>> To provide compatibility with automounters who use a common set of 
>>> mount
>>> options for all file systems, change the NFS in-kernel mount option 
>>> parser
>>> to ignore mount options it doesn't recognize.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> Yet another NFS mount patch!  Build tested only.  Comments?
>>>
>>>  fs/nfs/super.c |    7 ++-----
>>>  1 files changed, 2 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index f921902..a7201f0 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -1044,7 +1044,8 @@ static int nfs_parse_mount_options(char *raw,
>>>              break;
>>>  
>>>          default:
>>> -            goto out_unknown;
>>> +            printk(KERN_INFO "NFS: unrecognized mount option '%s'"
>>> +                    " ignored\n", p);
>>>          }
>>>      }
>>>  
>>> @@ -1070,10 +1071,6 @@ out_unrec_xprt:
>>>  out_unrec_sec:
>>>      printk(KERN_INFO "NFS: unrecognized security flavor\n");
>>>      return 0;
>>> -
>>> -out_unknown:
>>> -    printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
>>> -    return 0;
>>>  }
>>>  
>>>  /*
>>
>> This will potentially cause a very large number of messages to be
>> printed in a valid deployment.  Do we really need the message?
>
> I was wondering about that.
>
> I left it in because it's useful to know when a valid mount option is 
> misspelled.  In that case it might cause an important option (such as 
> "noac") to be ignored.

There do seem to be valid uses for the message.  However, it
could also end up being a bad thing.

Perhaps we could just gather the unknown options and lump
them together in something that would be visible via /proc/mounts
or some such.  Something like "unknown=..." in the options list.

       ps
