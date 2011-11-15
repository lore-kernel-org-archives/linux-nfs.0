Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48013 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756589Ab1KOVtA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Nov 2011 16:49:00 -0500
Message-ID: <4EC2DE49.5070000@netapp.com>
Date: Tue, 15 Nov 2011 16:48:57 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Pavel <free.lan.c2.718r@gmail.com>
CC: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: clients fail to reclaim locks after server reboot or manual sm-notify
References: <loom.20111114T180637-632@post.gmane.org> <4EC1678D.902@netapp.com> <4EC18E5F.4080101@netapp.com> <loom.20111115T142111-739@post.gmane.org>
In-Reply-To: <loom.20111115T142111-739@post.gmane.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/15/2011 10:50 AM, Pavel wrote:
> Bryan Schumaker <bjschuma@...> writes:
> 
>>
>> On Mon 14 Nov 2011 02:10:05 PM EST, Bryan Schumaker wrote:
>>> Hello Pavel,
>>>
>>> What kernel version is Debian using?  I haven't been able to reproduce the 
> problem using 3.0 (But I'm on
>> Archlinux, so there might be other differences).
> 
> Thanks, Bryan, for your reply.
> 
> Debian is using Linux kernel version 2.6.32 - I haven't upgraded it.
> 
>> It might also be useful if you could share the /etc/exports file on the 
>> server.
>>
>> Thanks!
>>
>> - Bryan
> 
> Thank you for the question - that was my rude mistake. For managing exports I'm 
> using OCF resource agent 'exportfs'. It uses Linux build-in command 'exportfs' 
> to export shares and /etc/exports file is empty. However Heartbeat starts much 
> later than NFS...Now it is clear why this wasn't working. Setting up share that 
> doesn't rely on Heartbeat resources, resolves the issue.
> 
> Still though, the first test was just to make sure NFS functions the way it is 
> supposed to, and not the goal - the second/main question remains open. When I 
> run sm-notify in this case, shares are already exported and all the other needed 
> resources are available as well. Why doesn't sm-notify work? It doesn't work 
> even in case of single server test. As of using files from /var/lib/nfs/sm/ when 
> notifying clients from the other node in cluster, it should be okay with -v 
> option of sm-notify, because it is a common practice to store the whole 
> /var/lib/nfs folder on shared storage in Active/Passive clusters and trigger sm-
> notify from the active node. It would be awesome if you could give me a clue.

I'm seeing the same thing you are using some Debian VMs I set up yesterday afternoon.  It does look like the server is replying with NLM_DENIED_GRACE_PERIOD when sm-notify is used.  Bruce, any idea what's going on here?

When I try using my Linux 3.0 / Archlinux machines I don't see any NLM requests due to sm-notify.  I'm not sure that's correct...

- Bryan

> 
>>>
>>> - Bryan
>>>
>>> On Mon 14 Nov 2011 12:11:56 PM EST, Pavel wrote:
>>>> Hi! I'm trying to set up an NFS server (particularly an A/A NFS cluster) 
> and 
>>>> having issues with locking and reboot notifications. These are the tests I 
> have 
>>>> done:
>>>>
>>>> 1. The simplest test includes single NFS server machine (Debian Squeeze), 
>>>> running nfs-kernel-server (nfs-utils 1.2.2-4) and a single client machine 
> (same 
>>>> OS), that mounts a share with “-o 'vers=3'” option. From the client I lock 
> some 
>>>> file on share using 'testlk -w <filename>' (testlk from 
> nfsutils/tools/locktest) 
>>>> so that a corresponding file appears in /var/lib/nfs/sm/ on server. Then I 
>>>> reboot the server and this is what I get in client logs:
>>>>
>>>> lockd: request from 127.0.0.1, port=1007
>>>> lockd: SM_NOTIFY     called
>>>> lockd: host nfs-server1 (192.168.0.101) rebooted, cnt 2
>>>> lockd: get host nfs-server1
>>>> lockd: get host nfs-server1
>>>> lockd: release host nfs-server1
>>>> lockd: reclaiming locks for host nfs-server1
>>>> lockd: rebind host nfs-server1
>>>> lockd: call procedure 2 on nfs-server1
>>>> lockd: nlm_bind_host nfs-server1 (192.168.0.101)
>>>> lockd: rpc_call returned error 13
>>>> lockd: failed to reclaim lock for pid 1555 (errno -13, status 0)
>>>> NLM: done reclaiming locks for host nfs-server1
>>>> lockd: release host nfs-server1
>>>>
>>>> 2. As I'm building a cluster I'll need to notify clients when NFS resource 
>>>> migrates (since it is an A/A cluster nfs-kernel-server is always running on 
> all 
>>>> nodes and shares migrate using exportfs resource agent), but manually 
> calling 
>>>> sm-notify ('sm-notify -f -v <virtual IP of share>') from either the initial 
> for 
>>>> that share or backup node results in the following (client logs):
>>>>
>>>> lockd: request from 127.0.0.1, port=637
>>>> lockd: SM_NOTIFY     called
>>>> lockd: host B (192.168.0.110) rebooted, cnt 2
>>>> lockd: get host B
>>>> lockd: get host B
>>>> lockd: release host B
>>>> lockd: reclaiming locks for host B
>>>> lockd: rebind host B
>>>> lockd: call procedure 2 on B
>>>> lockd: nlm_bind_host B (192.168.0.110)
>>>> lockd: server in grace period
>>>> lockd: spurious grace period reject?!
>>>> lockd: failed to reclaim lock for pid 2508 (errno -37, status 4)
>>>> NLM: done reclaiming locks for host B
>>>> lockd: release host B
>>>>
>>>> even though grace period is intended for lock reclamation. B/w after such 
>>>> invocation no files, corresponding to the notified clients, appear in 
>>>> /var/lib/nfs/sm/ on server for about 10 minutes, if I try locking from any 
> of 
>>>> these notified clients, even though locking itself is ok. Locking from 
> other 
>>>> clients generates files for them instantly.
>>>>
>>>> As of the rest: simple concurrent lock tests from couple of clients work 
> fine as 
>>>> well as server frees locks of rebooted clients.
>>>>
>>>> I'm new to NFS an may be missing obvious things, but I've already spent 
> several 
>>>> days googling around, but don't seem to find any solution.
>>>> Any help or guidance is highly appreciated. Thanks!
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@...
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@...
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@...
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

