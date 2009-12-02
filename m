From: Diego Moreno <Diego.Moreno-Lazaro@bull.net>
Subject: Re: rpc.statd problem: lockd: cannot monitor server
Date: Wed, 02 Dec 2009 11:22:49 +0100
Message-ID: <4B163FF9.9050700@bull.net>
References: <4B154EE7.8050700@bull.net> <98062189-30B8-4AF6-8F6F-4534495230C2@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:37546 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbZLBKZs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2009 05:25:48 -0500
In-Reply-To: <98062189-30B8-4AF6-8F6F-4534495230C2@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Dec 1, 2009, at 12:14 PM, Diego Moreno wrote:
>> Hi guys,
>>
>> We are having a problem with locks in NFSv3 with Fedora11. I've been 
>> searching this problem in the list for a while but I haven't found it.
>>
>> The problem is in Fedora11, kernel 2.6.29.6-217.2.16.fc11 and 
>> nfs-utils-1.1.5-6.fc11
>>
>> When I try to make two locks with two different process I get the 
>> message "No locks available". rpc.statd is running on client and 
>> server, also lockd. If I try with just one process I obtain the same 
>> result.
>>
>> I tried to debug with wireshark and I can see client is not trying to 
>> make a lock. I also tried to enable NLM debug and I get next messages:
>>
>> Syslog:
>>
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> get host myserver
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> get host myserver
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> nsm_monitor(myserver)
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> get host myserver
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> get host myserver
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> nsm_monitor(myserver)
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> xdr_dec_stat_res status 1 state -1
>> 1259574201 2009 Nov 30 10:43:21 myclient kern notice kernel lockd: 
>> cannot monitor myserver
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> release host myserver
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> release host myserver
>> 1259574201 2009 Nov 30 10:43:21 myclient daemon warning rpc.statd 
>> creat(/var/lib/nfs/statd/sm/myserver) failed: No such file or directory
>> 1259574201 2009 Nov 30 10:43:21 myclient daemon notice rpc.statd 
>> STAT_FAIL to myclient for SM_MON of 10.0.4.60
>> 1259574201 2009 Nov 30 10:43:21 myclient daemon warning rpc.statd 
>> creat(/var/lib/nfs/statd/sm/myserver) failed: No such file or directory
> 
> Statd can't create the monitor record for this remote peer for some 
> reason.  Check that /var/lib/nfs/statd and /var/lib/nfs/statd/sm exist, 
> and are permitted so that rpc.statd can create files in it.  Check which 
> uid and gid statd is running under: I think F11 uses 29 for both.
>

Thanks Chuck. That made the trick. Directory /var/lib/nfs/statd/ was 
empty in client and server. Adding these directories locking works. But 
it's just a workaround as I have 30 more clients having the same 
problem. I'm going to try to find out why this is happening. Maybe it is 
a bug in fedora installation? When are supposed the files under 
"/var/lib/nfs/statd/" to be created?

statd is running under the right uid and gid and /var/lib/nfs/statd is 
owned by rpcuser as it should be.

>> 1259574201 2009 Nov 30 10:43:21 myclient daemon notice rpc.statd 
>> STAT_FAIL to myclient for SM_MON of 10.0.4.60
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> clnt proc returns -37
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> xdr_dec_stat_res status 1 state -1
>> 1259574201 2009 Nov 30 10:43:21 myclient kern notice kernel lockd: 
>> cannot monitor myserver
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> release host myserver
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> release host myserver
>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>> clnt proc returns -37
>>
>> It's like if rpc.statd was not running, but it is. Should ../statd/sm/ 
>> directory be already created when we try the lock?
>>
>> Is this a known problem?
>>
>> Thanks,
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
