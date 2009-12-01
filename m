From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: rpc.statd problem: lockd: cannot monitor server
Date: Tue, 1 Dec 2009 12:34:53 -0500
Message-ID: <98062189-30B8-4AF6-8F6F-4534495230C2@oracle.com>
References: <4B154EE7.8050700@bull.net>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Diego Moreno <Diego.Moreno-Lazaro@bull.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:21153 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbZLARfB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Dec 2009 12:35:01 -0500
In-Reply-To: <4B154EE7.8050700@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 1, 2009, at 12:14 PM, Diego Moreno wrote:
> Hi guys,
>
> We are having a problem with locks in NFSv3 with Fedora11. I've been  
> searching this problem in the list for a while but I haven't found it.
>
> The problem is in Fedora11, kernel 2.6.29.6-217.2.16.fc11 and nfs- 
> utils-1.1.5-6.fc11
>
> When I try to make two locks with two different process I get the  
> message "No locks available". rpc.statd is running on client and  
> server, also lockd. If I try with just one process I obtain the same  
> result.
>
> I tried to debug with wireshark and I can see client is not trying  
> to make a lock. I also tried to enable NLM debug and I get next  
> messages:
>
> Syslog:
>
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> get host myserver
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> get host myserver
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> nsm_monitor(myserver)
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> get host myserver
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> get host myserver
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> nsm_monitor(myserver)
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> xdr_dec_stat_res status 1 state -1
> 1259574201 2009 Nov 30 10:43:21 myclient kern notice kernel lockd:  
> cannot monitor myserver
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> release host myserver
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> release host myserver
> 1259574201 2009 Nov 30 10:43:21 myclient daemon warning rpc.statd  
> creat(/var/lib/nfs/statd/sm/myserver) failed: No such file or  
> directory
> 1259574201 2009 Nov 30 10:43:21 myclient daemon notice rpc.statd  
> STAT_FAIL to myclient for SM_MON of 10.0.4.60
> 1259574201 2009 Nov 30 10:43:21 myclient daemon warning rpc.statd  
> creat(/var/lib/nfs/statd/sm/myserver) failed: No such file or  
> directory

Statd can't create the monitor record for this remote peer for some  
reason.  Check that /var/lib/nfs/statd and /var/lib/nfs/statd/sm  
exist, and are permitted so that rpc.statd can create files in it.   
Check which uid and gid statd is running under: I think F11 uses 29  
for both.

> 1259574201 2009 Nov 30 10:43:21 myclient daemon notice rpc.statd  
> STAT_FAIL to myclient for SM_MON of 10.0.4.60
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> clnt proc returns -37
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> xdr_dec_stat_res status 1 state -1
> 1259574201 2009 Nov 30 10:43:21 myclient kern notice kernel lockd:  
> cannot monitor myserver
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> release host myserver
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> release host myserver
> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd:  
> clnt proc returns -37
>
> It's like if rpc.statd was not running, but it is. Should ../statd/ 
> sm/ directory be already created when we try the lock?
>
> Is this a known problem?
>
> Thanks,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




