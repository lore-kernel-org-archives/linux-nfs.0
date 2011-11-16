Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30379 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757827Ab1KPOZU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Nov 2011 09:25:20 -0500
Message-ID: <4EC3C7BD.6060407@netapp.com>
Date: Wed, 16 Nov 2011 09:25:01 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Pavel <free.lan.c2.718r@gmail.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: clients fail to reclaim locks after server reboot or manual sm-notify
References: <loom.20111114T180637-632@post.gmane.org> <4EC1678D.902@netapp.com> <4EC18E5F.4080101@netapp.com> <loom.20111115T142111-739@post.gmane.org> <4EC2DE49.5070000@netapp.com> <20111115221623.GA12453@fieldses.org>
In-Reply-To: <20111115221623.GA12453@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 15 Nov 2011 05:16:23 PM EST, J. Bruce Fields wrote:
> On Tue, Nov 15, 2011 at 04:48:57PM -0500, Bryan Schumaker wrote:
>> On 11/15/2011 10:50 AM, Pavel wrote:
>>> Bryan Schumaker <bjschuma@...> writes:
>>>
>>>>
>>>> On Mon 14 Nov 2011 02:10:05 PM EST, Bryan Schumaker wrote:
>>>>> Hello Pavel,
>>>>>
>>>>> What kernel version is Debian using?  I haven't been able to reproduce the 
>>> problem using 3.0 (But I'm on
>>>> Archlinux, so there might be other differences).
>>>
>>> Thanks, Bryan, for your reply.
>>>
>>> Debian is using Linux kernel version 2.6.32 - I haven't upgraded it.
>>>
>>>> It might also be useful if you could share the /etc/exports file on the 
>>>> server.
>>>>
>>>> Thanks!
>>>>
>>>> - Bryan
>>>
>>> Thank you for the question - that was my rude mistake. For managing exports I'm 
>>> using OCF resource agent 'exportfs'. It uses Linux build-in command 'exportfs' 
>>> to export shares and /etc/exports file is empty. However Heartbeat starts much 
>>> later than NFS...Now it is clear why this wasn't working. Setting up share that 
>>> doesn't rely on Heartbeat resources, resolves the issue.
>>>
>>> Still though, the first test was just to make sure NFS functions the way it is 
>>> supposed to, and not the goal - the second/main question remains open. When I 
>>> run sm-notify in this case, shares are already exported and all the other needed 
>>> resources are available as well. Why doesn't sm-notify work? It doesn't work 
>>> even in case of single server test. As of using files from /var/lib/nfs/sm/ when 
>>> notifying clients from the other node in cluster, it should be okay with -v 
>>> option of sm-notify, because it is a common practice to store the whole 
>>> /var/lib/nfs folder on shared storage in Active/Passive clusters and trigger sm-
>>> notify from the active node. It would be awesome if you could give me a clue.
>>
>> I'm seeing the same thing you are using some Debian VMs I set up yesterday afternoon.  It does look like the server is replying with NLM_DENIED_GRACE_PERIOD when sm-notify is used.  Bruce, any idea what's going on here?
>
> Sorry, I'm having trouble keeping up....  What exactly do you do, on
> which machine, and what do you then see happen?

Here is what I'm doing (On debian with 2.6.32):
- (On Client) Mount the server: `sudo mount -o vers=3 
192.168.122.202:/home/bjschuma /mnt`
- (On Client) Lock a file using nfs-utils/tools/locktest: `./testlk 
/mnt/test`
- (On Server) Call sm-notify with the server's IP address: `sudo 
sm-notify -f -v 192.168.122.202`
- dmesg on the client has this message:
    lockd: spurious grace period reject?!
    lockd: failed to reclaim lock for pid 2099 (errno -37, status 4)
- (In wireshark) The client sends a lock request with the "Reclaim" bit 
set to "yes" but the server replies with "NLM_DENIED_GRACE_PERIOD".

Shouldn't the server be allowing the lock reclaim?  When I tried 
yesterday using 3.0 it only triggered DNS packets, I tried again a few 
minutes ago and got the same results that I did using .32.

- Bryan

>
> --b.
>
>>
>> When I try using my Linux 3.0 / Archlinux machines I don't see any NLM requests due to sm-notify.  I'm not sure that's correct...
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


