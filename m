Received: from ssl.schu.net (ssl.schu.net [136.143.158.4])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69D28288B1
	for <linux-nfs@vger.kernel.org>; Mon,  9 Mar 2026 23:46:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=136.143.158.4
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773100016; cv=none; b=DH7wDDbKLhoepFkPrrKamXxWvDWasYH9aSVd0jO15KjmUroTOJgVlKOzwPtxiM7QnE2Ckmx/A1sA551vzsxog/nBvHRXcpHKY54meCH6BAaz78DSraIJAkGjQmBTZg0cj+q0nJG8l2r3ARk9EOXvP9B/bEJ0nzNbz0NSBBFC7LM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773100016; c=relaxed/simple;
	bh=pv/8tCiCBQkxRiBm5HgdYjocchnLcqXb7+WSRsUF/84=;
	h=Message-ID:Date:MIME-Version:Subject:From:To:References:
	 In-Reply-To:Content-Type; b=s55Wf8iQwAMy+PbwkJblTx/UaUJPVUH9GojOtXuDNGkNY0LJSs9pOIvw+BUXWveSFJ7EPHhQiWhZtDKyLvUDEojSE53TyCPmYGgdhLzAL14G4TYg8YlshzKSdrZ5DlQWBibZCkhfY09GcWWhWtGui62busHEOJNnQmqX4VA9pc4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=schu.net; spf=pass smtp.mailfrom=schu.net; dkim=pass (2048-bit key) header.d=schu.net header.i=schu@schu.net header.b=o89NLq8x; arc=none smtp.client-ip=136.143.158.4
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=schu.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=schu.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=schu.net header.i=schu@schu.net header.b="o89NLq8x"
Received: from [192.168.120.145] (2-97-186-64.aptalaska.net [64.186.97.2])
	(authenticated bits=0)
	by ssl.schu.net (8.15.2/8.15.2) with ESMTPSA id 629NkrQK007383
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 9 Mar 2026 16:46:54 -0700
Message-ID: <0173f679-f646-4d8b-afb0-3ec968d6c22b@schu.net>
Date: Mon, 9 Mar 2026 16:46:52 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Current state of nfsdv4 recovery.
From: Matthew Schumacher <schu@schu.net>
To: linux-nfs@vger.kernel.org
References: <0d586513-819c-4af9-8c9f-8d09d326e547@schu.net>
 <1fcd27cb44217d5db08e488528a2648c2906a435.camel@kernel.org>
 <6214ba33-1ed3-4c8b-bba1-8d4894cb2dd1@schu.net>
Content-Language: en-US
In-Reply-To: <6214ba33-1ed3-4c8b-bba1-8d4894cb2dd1@schu.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spam-Report: Content analysis details:   (-2.5 points)
	pts  rule name              description
	---- ---------------------- -------------------------------------------
	-1.0 ALL_TRUSTED            Passed through trusted hosts only via SMTP
	-1.5 BAYES_00               BODY: Bayes spam probability is 0 to 1%
	                            [score: 0.0000]
X-Spam-Bayes: Learn: no autolearn_force=no
X-Spam-Score: No, -2.5 hits
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed; d=schu.net; h=message-id
	:date:mime-version:subject:from:to:references:in-reply-to
	:content-type:content-transfer-encoding; s=schu; i=
	schu@schu.net; t=1773100014; bh=pv/8tCiCBQkxRiBm5HgdYjocchnLcqXb
	7+WSRsUF/84=; b=o89NLq8xGF6h9Ea3OitBXyCV2XGkQhyIOyRUoVCxf62+EjNE
	qqML8DVdRqc3Z2Fj/luQAclvzJZb0Az18KRH9yU8L5EVXhDZNbU2C3o3OrEzbd+7
	rcRf2KnUt3FWqYjohKSRTeNDXRHq6kncjoVhf6IjUqyUuILTHiB48dac3VkO714Y
	0FIw/lEA2OcM088WLfSI9te+IYMyPVBi5qENTsn3DloMu1GyN5WJOgjZIvMlPzBA
	8a+TyxlVkBbSPe/lwCzLPoMM+OYQIfOzIHVOT59hU1+gihU4krAukhRZnUHDVg0l
	ioJcRXL4dVn03Ol7W3luUm7ahfOIjgJWYZTldg==
X-Scanned-By: MIMEDefang 3.2 on 192.168.98.12

On 3/9/26 11:57 AM, Matthew Schumacher wrote:
> On 3/6/26 12:49 PM, Jeff Layton wrote:
>> On Fri, 2026-03-06 at 11:46 -0800, Matthew Schumacher wrote:
>>> Hello List,
>>>
>>> I am building an HA nfsv4 cluster and need to have my locking migrate
>>> when a node fails or goes into standby for maint.  There is a lot of
>>> documentation around the net, but some of it seems old, like this:
>>> https://wiki.linux-nfs.org/wiki/index.php/Nfsd4_server_recovery. I 
>>> think
>>> I have what I need worked out, but I'm still losing locks on recovery.
>>> Can someone help me understand how this currently works or point me to
>>> the up to date documentation?
>>>
>>> This is what I'm currently doing:
>>>
>>> Moving from nodeA to nodeB
>>>
>>> NodeA: Remove nfsd ip address
>>> NodeA: /usr/sbin/exportfs -au
>>> NodeA: /usr/sbin/rpc.nfsd 0
>>> NodeA: killall --ns $$ -q -v -w rpc.mountd
>>> NodeA: killall --ns $$ -q -v -w nfsdcld
>>> NodeA: killall --ns $$ -q -v -w rpc.idmapd
>>> NodeA: killall --ns $$ -q -v -w rpcbind
>>> NodeA: umount /var/lib/nfs/rpc_pipefs
>>> NodeA: zpool export (which umounts /var/lib/nfs)
>>>
>>> NodeB: zpool import (which mounts /var/lib/nfs)
>>> NodeB: mount /proc/fs/nfs if not previously mounted
>>> NodeB: mount -t rpc_pipefs -o nodev sunrpc /var/lib/nfs/rpc_pipefs
>>> NodeB: /sbin/rpcbind -l -w
>>> NodeB: /usr/sbin/rpc.idmapd
>>> NodeB: /usr/sbin/nfsdcld -d
>>> NodeB: /usr/sbin/exportfs -av
>>> NodeB: /usr/sbin/rpc.mountd
>>> NodeB: /usr/sbin/rpc.nfsd -s -V 4.2 -U -t 8
>>> NodeB: start nfsd ip address
>>>
>>>   From what I understand, nfsdcld writes the lock information to
>>> /var/lib/nfs/nfsdcltrack/main.sqlite which is moved to the other side
>>> and everything is started, but I still lose locks when I migrate.
>>>
>>> Mar  6 08:39:14 nfsha user.warn kernel: [37675.787509] NFS:
>>> 10.255.255.3: lost 1 locks
>>>
>>> I think the problem is that kernel (6.12.74) isn't getting the locks
>>> reported to it when nfsdcld starts.  Here are some logs:
>>>
> <snip old logs>
>>>
>>> I think the problem is that nfsdcld can't pass the locks to the kernel
>>> using /var/lib/nfs/rpc_pipefs/nfsd/cld as it's missing.  I'm not sure
>>> why, /var/lib/nfs/rpc_pipefs/ has everything else:
>>>
> <snip old pipefs>
>>>
>>
>> That's very odd. You might want to look in dmesg and see if there are
>> any warnings in there about creating the pipes in rpc_pipefs.
>>
>
>
> Hello Jeff, others...
> I did get nfsdcld to talk to the kernel, but I still lose my sessions 
> when I move NFS from one node to another.  I wonder if my 
> understanding is correct:
>
> If I have /var/lib/nfs mounted, and nfsdcld running, then it should 
> persist my sessions and locks to the main.sqlite database, then when I 
> shut down nfsdcld, umount /var/lib/nfs, then mount /var/lib/nfs on a 
> different node and start nfsdcld it should tell the kernel about my 
> sessions and locks and everything keep working.
>
> Is that correct?
>
> Right now I see my client happily working with a session:
>
> Mar  9 11:39:46 nodeA user.warn kernel: [245803.517797] 
> encode_sequence: sessionid=1773078573:732586373:19:0 seqid=1939 
> slotid=0 max_slotid=0 cache_this=0
>
> Then when I move the NFS server to another node and assume the same IP 
> address, the clients session is reset:
>
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155392] 
> nfs41_sequence_process ERROR: -10052 Reset session
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155394] 
> nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155396] 
> nfs41_sequence_process: Error -10052 free the slot
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155397] 
> nfs41_sequence_call_done ERROR -10052
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155397] 
> nfs4_schedule_lease_recovery: scheduling lease recovery for server 
> 10.255.255.3
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155411] 
> nfs41_sequence_call_done rpc_cred 000000009fd26b60
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155413] 
> nfs4_schedule_state_renewal: requeueing work. Lease period = 5
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155570] NFS: Got error 
> -10052 from the server on DESTROY_SESSION. Session has been destroyed 
> regardless...
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155572] --> 
> nfs4_proc_create_session clp=00000000ea3d2c57 session=00000000348f3ed3
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155574] 
> nfs4_init_channel_attrs: Fore Channel : max_rqst_sz=1049620 
> max_resp_sz=1049480 max_ops=8 max_reqs=64
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155576] 
> nfs4_init_channel_attrs: Back Channel : max_rqst_sz=4096 
> max_resp_sz=4096 max_resp_sz_cached=0 max_ops=2 max_reqs=16
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155732] 
> nfs4_reset_session: session reset failed with status -10022 for server 
> 10.255.255.3!
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155734] 
> nfs4_handle_reclaim_lease_error: handled error -10022 for server 
> 10.255.255.3
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.155946] 
> _nfs4_proc_exchange_id: server_scope mismatch detected
> Mar  9 11:45:55 nodeA user.warn kernel: [246172.193390] NFS: 
> 10.255.255.3: lost 1 locks
>
<snip>

Replying to the list...

It appears my assumption is correct because now I see my locks and 
sessions maintained when moving from nodeA to nodeB... the issue was this:

_nfs4_proc_exchange_id: server_scope mismatch detected

The scope must be the same on all nodes in a cluster and defaults to the 
node hostname.

My cluster is happy doing nfsv4 now.

