From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Only warn on unrecognized mount options
Date: Mon, 14 Apr 2008 10:00:37 -0400
Message-ID: <2832BD5F-D944-41FD-9FF1-1EC4D4DFA5E0@oracle.com>
References: <20080411200249.28007.12509.stgit@manray.1015granger.net> <1207945499.15646.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:36378 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336AbYDNOBr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 10:01:47 -0400
In-Reply-To: <1207945499.15646.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 11, 2008, at 4:24 PM, Trond Myklebust wrote:
> On Fri, 2008-04-11 at 16:03 -0400, Chuck Lever wrote:
>> To provide compatibility with automounters who use a common set of  
>> mount
>> options for all file systems, change the NFS in-kernel mount option  
>> parser
>> to ignore mount options it doesn't recognize.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> Yet another NFS mount patch!  Build tested only.  Comments?
>>
>> fs/nfs/super.c |    7 ++-----
>> 1 files changed, 2 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index f921902..a7201f0 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -1044,7 +1044,8 @@ static int nfs_parse_mount_options(char *raw,
>> 			break;
>>
>> 		default:
>> -			goto out_unknown;
>> +			printk(KERN_INFO "NFS: unrecognized mount option '%s'"
>> +					" ignored\n", p);
>> 		}
>> 	}
>>
>> @@ -1070,10 +1071,6 @@ out_unrec_xprt:
>> out_unrec_sec:
>> 	printk(KERN_INFO "NFS: unrecognized security flavor\n");
>> 	return 0;
>> -
>> -out_unknown:
>> -	printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
>> -	return 0;
>> }
>>
>> /*
>
> This isn't really a very good solution either. Spamming the syslog on
> every option that is being ignored isn't going to help the folks with
> the global automounter maps. Either the rules should be that 'all
> options are allowed' or they should be that 'only recognised NFS  
> options
> are allowed'.


Despite what I posted last week, I like the code the way it is now:   
We should reject any unrecognized mount options with an error  
message.  Anything else invites subtle behavior problems, security  
holes, or even the possibility of data corruption.

Oracle databases, for example, do rely on "sync" mounts actually being  
synchronous.  If you specify Kerberos security but misspell it, I  
think you would want to know that you're not getting the security  
level you expect.

Can someone (maybe Peter) help me understand how exactly this makes  
using an automounter problematic?

Thanks!

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
