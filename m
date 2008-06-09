From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/4] Python scripts for analyzing NFS/RPC metrics
Date: Mon, 9 Jun 2008 14:42:59 -0400
Message-ID: <4FCA1C50-013E-4B02-8F7D-B9E041E15BE4@oracle.com>
References: <20080609163029.5461.35699.stgit@ellison.1015granger.net> <RTPCLUEXC1-PRDVIdGs000001d6@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:19682 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbYFISpL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2008 14:45:11 -0400
In-Reply-To: <RTPCLUEXC1-PRDVIdGs000001d6-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 9, 2008, at 1:11 PM, Talpey, Thomas wrote:
> By the way. I love these scripts. The best thing about them is the
> way they actually analyze the realtime performance of each RPC
> procedure and server mount point including latencies and queuing,
> which are nearly impossible to figure out with the commandline.
> For example, they instantly tell whether the RPC slot table is too
> small (or large) for the workload.

Thanks!

I'm hoping that including these in nfs-utils will help polish them a  
bit so that more people can understand and use them effectively.   
Steve mentioned something at Connectathon about interns and man  
pages... ;-)

> At 12:47 PM 6/9/2008, Chuck Lever wrote:
>> Hi Steve-
>>
>> As promised, here are the Python scripts that I've implemented for  
>> analyzing
>> NFS and RPC performance metrics reported via /proc/self/ 
>> mountstats.  They
>> still need man pages and proper installation in the nfs-utils  
>> Makefile.
>>
>> While we decide whether to install and support these scripts as  
>> they are, or
>> to replace them with C language re-implementations, let's include  
>> them in
>> nfs-utils now so folks can try them out, bugs can be addressed, and  
>> missing
>> features provided.
>>
>> ---
>>
>> Chuck Lever (2):
>>     Import the old iostat-ms Python script
>>     Import mountstats utility
>>
>> Tom Talpey (2):
>>     NFS iostats - add RDMA statistics
>>     NFS mountstats - add RDMA statistics
>>
>>
>> tools/mountstats/mountstats.py |  604 ++++++++++++++++++++++++++++++ 
>> ++++++++++
>> tools/nfs-iostat/nfs-iostat.py |  564 ++++++++++++++++++++++++++++++ 
>> +++++++
>> 2 files changed, 1168 insertions(+), 0 deletions(-)
>> create mode 100755 tools/mountstats/mountstats.py
>> create mode 100755 tools/nfs-iostat/nfs-iostat.py
>>
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



