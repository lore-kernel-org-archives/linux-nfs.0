From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: svc: failed to register lockdv1 RPC service (errno 97).
Date: Mon, 29 Jun 2009 10:15:50 -0400
Message-ID: <6CB29B19-A6D2-4FFB-9BCB-CC248540CACB@oracle.com>
References: <200905110248.48695.elendil@planet.nl> <8054CA42-CAFC-4DFC-A3A9-107AF29284EE@oracle.com>  <200905111639.43636.elendil@planet.nl> <62189277-05F4-4AC7-97EC-AFDE39F781E3@oracle.com> <25ae2d690906282333j7c9cb5b9nb954470e0694c3ce@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Frans Pop <elendil@planet.nl>, Netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: db <db.pub.mail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <25ae2d690906282333j7c9cb5b9nb954470e0694c3ce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 29, 2009, at 2:33 AM, db wrote:
> I'm running arm 2.6.30 kernel and a 2.6.30 kernel on my desktop.
>
> I see this  "[1257016.190000] nfsd: last server has exited, flushing
> export cache
> [1257018.250000] svc: failed to register lockdv1 RPC service (errno  
> 97).
> ."
> On both ends. The arm is running debian lenny (armel). The desktop is
> debian lenny (32bit i368). When this error i cannot continue to
> transfer files.

Right at the moment I think this message is a coincidence.  But let's  
chase it a little and see what we get.

First, you provided a couple of kernel log snippets here, but you  
didn't identify which snippet comes from your server, and which from  
your client.  I assume the above one comes from your server, and the  
below comes from your client.

Do you happen to have IPv6 configured on your systems ("ifconfig - 
a")?  What is the output of "rpcinfo" on your client and on your  
server?  Are you running portmap or rpcbind on these systems?

> Here is the config of the /etc/exports and what i try to use
>
> "/media/nfs_shares/rsync/  *(rw,no_subtree_check)"
> i mount on the desktop with
>
> [root@desktop ]# mount 192.168.1.12:/media/Y/W/  /media/mount_point/  
> -o soft

"cat /proc/mounts" on your client so we can see exactly what mount  
options the kernel has chosen.

> and i try using rsync like this (from my desktop).
>
>
> rsync -av --progress /home/User_NAME/BACKUP/Y/W/X/ /media/ 
> mount_point/W/X
> and it just hangs. I then try to unmount it and i have problems doing
> so. so i need to force the umount
>
> "19051.391800]     Performance counters on
> [319051.391804]     input device check on
> [319051.391807]     Actions configured
> [399843.223405] RPC: Registered udp transport module.
> [399843.223413] RPC: Registered tcp transport module.
> [399843.346956] svc: failed to register lockdv1 RPC service (errno  
> 97).
> [401465.708049] device eth1 left promiscuous mode
> [401689.794716] svc: failed to register lockdv1 RPC service (errno  
> 97).
> [402224.640535] svc: failed to register lockdv1 RPC service (errno  
> 97).
> [402356.791524] svc: failed to register lockdv1 RPC service (errno  
> 97).
> [402702.197491] svc: failed to register lockdv1 RPC service (errno  
> 97).
> "
> I am only using nfs2. I am not using nfs4 / nfs3.
>
> This issue is most troublesome as it breaks my use of nfs.

Have you captured a network trace?   Start the trace before mounting  
the server.  I usually use something like "sudo tethereal -w /tmp/raw" .

> 2009/5/12 Chuck Lever <chuck.lever@oracle.com>:
>> On May 11, 2009, at 10:39 AM, Frans Pop wrote:
>>>
>>> On Monday 11 May 2009, you wrote:
>>>>
>>>> On May 10, 2009, at 8:48 PM, Frans Pop wrote:
>>>>>
>>>>> After switching from 2.6.29.2 to 2.6.30-rc5 I get this new message
>>>>> during boot of my home server:
>>>>>  svc: failed to register lockdv1 RPC service (errno 97).
>>>>
>>>> Is this the only instance of this message, or do you see it several
>>>> times?
>>>
>>> It's the only one.
>>>
>>>>> This looks to be the result of the following commit:
>>>>> commit 363f724cdd3d2ae554e261be995abdeb15f7bdd9
>>>>> Author: Chuck Lever <chuck.lever@oracle.com>
>>>>>  SUNRPC: rpcb_register() should handle errors silently
>>>>>  Move error reporting for RPC registration to rpcb_register's
>>>>> caller.
>>>>>
>>>>> Question is: do I really want to know this? I assume the "failure"
>>>>> happened with previous kernels too, but silently.
>>>>
>>>> The point of that commit was to report errors _less_ frequently.
>>>
>>> :-)
>>>
>>>> The server-side RPC code is attempting to be more automatic about
>>>> which address families are supported by kernel NFS services.  This
>>>> message tells us that some particular case is not handled yet.  I
>>>> suspect you weren't seeing this error in the past at all.
>>>
>>> Correct. Neither this exact error, nor anything remotely similar.
>>
>> No, I meant that whether or not you saw an error message, the  
>> underlying
>> condition probably was not occurring before 2.6.30.
>>
>>>> Can you report more about your server configuration?  What
>>>> distribution is this?
>>>
>>> Debian stable (Lenny).
>>> nfs-common and nfs-kernel-server (1.1.2)
>>>
>>> I'm using nfs4. rpc.statd is not running; rpc.mountd and  
>>> rpc.idmapd are.
>>
>> The NFS client and server appear to start lockd listeners for  
>> NFSv4.  They
>> probably don't need to.  But that's a separate issue.
>>
>>>> Does user space have portmapper or rpcbind?
>>>
>>> portmap (6.0)
>>>
>>>> Are you blacklisting ipv6.ko?
>>>
>>> No, the server has IPv6 enabled.
>>> I'm using NFS mainly from my laptop though, which does not have an  
>>> IPv6
>>> address for my home network.
>>>
>>>> What's the output of "rpcinfo" on your server after it has  
>>>> started NFSD?
>>>
>>> I guess you mean the -p option?
>>>
>>> $ rpcinfo -p
>>>  program vers proto   port
>>>   100000    2   tcp    111  portmapper
>>>   100000    2   udp    111  portmapper
>>>   100003    2   udp   2049  nfs
>>>   100003    3   udp   2049  nfs
>>>   100003    4   udp   2049  nfs
>>>   100021    1   udp  47955  nlockmgr
>>>   100021    3   udp  47955  nlockmgr
>>>   100021    4   udp  47955  nlockmgr
>>>   100021    1   tcp  41860  nlockmgr
>>>   100021    3   tcp  41860  nlockmgr
>>>   100021    4   tcp  41860  nlockmgr
>>>   100003    2   tcp   2049  nfs
>>>   100003    3   tcp   2049  nfs
>>>   100003    4   tcp   2049  nfs
>>>   100005    1   udp  40032  mountd
>>>   100005    1   tcp  40623  mountd
>>>   100005    2   udp  40032  mountd
>>>   100005    2   tcp  40623  mountd
>>>   100005    3   udp  40032  mountd
>>>   100005    3   tcp  40623  mountd
>>>   391002    2   tcp    792  sgi_fam
>>
>> In this case, it looks like the message can be treated as a  
>> notice.  I think
>> in general we could safely make that a dprintk, but I'd like to  
>> wait a bit
>> more to see if we catch any bad behavior.
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



