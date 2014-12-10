Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757944AbaLJPdp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 10:33:45 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBAFXid5012903
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 10:33:45 -0500
Message-ID: <548867D6.5050703@redhat.com>
Date: Wed, 10 Dec 2014 10:33:42 -0500
From: Dave Sullivan <dsulliva@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
CC: David Swegen <dswegen@redhat.com>
Subject: Re: possible better error handling for nfsv4 and localhost maps
References: <5481CD2F.4060607@redhat.com> <54833114.3090708@RedHat.com>
In-Reply-To: <54833114.3090708@RedHat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/06/2014 11:38 AM, Steve Dickson wrote:
>
>
> On 12/05/2014 10:20 AM, Dave Sullivan wrote:
>> Hi All,
>>
>> Recently we had a customer with some legacy maps using localhost run into a problem with NFSv4.
>>
>> They are not quite ready to get rid of those localhost maps.
>>
>> There is a fairly straight forward workaround/solution to get around this issue by modifying /etc/nfsmount.conf with
>>
>> [ Server "localhost" ]
>>     Nfsvers=3
>>
>> What we are asking for is better error handling so users can figure out what the problem is without having to debug as much.
>>
>> i.e. Have the code not retry and have the code send a notification to syslog saying something like "nfsv4 does not support localhost maps, man nfsmount.conf, use [ Server "localhost" ] with Nfsvers=3 mount option to restrict localhost maps to NFSv3"
>>
>> Here's an example of effort required to debug
>>
>> Description of problem:
>>
>> The RHEL automounter does try to do what’s inferred in the above notation, ie, make a bind mount.  What happens next, when the local filesystem doesn’t exist, is what’s causing us a problem.  It next spawns a mount request to an NFS service on localhost for the mount, either via IPV6, or via IPV4;  end-user hosts don’t serve NFS, so the problem arises due to how this is handled.
>>
>> On RHEL5, the mount request contacts the portmapper, which reports there is no program registered for NFS service, and the mount fails straight away.
>>
>> On RHEL6, if /etc/hosts has an entry for the IPV6 localhost address, an NFS mount from IPV6 localhost gets tried first, which fails immediately as expected, as IPV6 is not enabled, and no NFS service is registered on the host.  Automount reports the mount failure straight away.
>> Hi All,
>>
>> Recently we had a customer with some legacy maps using localhost run into a problem with NFSv4.
>>
>> They are not quite ready to get rid of those localhost maps.
>>
>> There is a fairly straight forward workaround/solution to get around this issue by modifying /etc/nfsmount.conf with
>>
>> [ Server "localhost" ]
>>     Nfsvers=3
>>
>> What we are asking for is better error handling so users can figure out what the problem is without having to debug as much.
>>
>> i.e. Have the code not retry and have the code send a notification to syslog saying something like "nfsv4 does not support localhost maps, man nfsmount.conf, use [ Server "localhost" ] with Nfsvers=3 mount option to restrict localhost maps to NFSv3"
>>
>> Here's an example of effort required to debug
>>
>> Description of problem:
>>
>> The RHEL automounter does try to do what’s inferred in the above notation, ie, make a bind mount.  What happens next, when the local filesystem doesn’t exist, is what’s causing us a problem.  It next spawns a mount request to an NFS service on localhost for the mount, either via IPV6, or via IPV4;  end-user hosts don’t serve NFS, so the problem arises due to how this is handled.
>>
>> On RHEL5, the mount request contacts the portmapper, which reports there is no program registered for NFS service, and the mount fails straight away.
>>
>> On RHEL6, if /etc/hosts has an entry for the IPV6 localhost address, an NFS mount from IPV6 localhost gets tried first, which fails immediately as expected, as IPV6 is not enabled, and no NFS service is registered on the host.  Automount reports the mount failure straight away.
>>
>> On RHEL6 however, if /etc/hosts does not have an entry for the IPV6 localhost address, automount tries the IPV4 localhost address; when the mount is requested using NFSv4, the RPC request seem to get localhost port 0 returned for NFS service, instead of being told there is no program registered for NFS service (if I’m reading this strace correctly):
>>
>> 1657  1416223283.572722 socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
>> 1657  1416223283.572764 bind(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
>> 1657  1416223283.572811 connect(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.1")}, 16) = 0
>> 1657  1416223283.572849 getsockname(3, {sa_family=AF_INET, sin_port=htons(40477), sin_addr=inet_addr("127.0.0.1")}, [16]) = 0
>> 1657  1416223283.572896 mount("localhost:/local/0/blah", "/mnt/test", "nfs", 0, "vers=4,addr=127.0.0.1,clientaddr"...) = -1 ECONNREFUSED (Connection refused)
>>
>> The mount continues to pause and retry, until it reaches the retry limit, and then eventually fails.  Here’s what the bare mount command shows:
>>
>> [root@lonlx8001b13 bevaja]# mount -vvv -t nfs -o nfsvers=4 localhost:/local/0/blah /mnt/test
>> mount: fstab path: "/etc/fstab"
>> mount: mtab path:  "/etc/mtab"
>> mount: lock path:  "/etc/mtab~"
>> mount: temp path:  "/etc/mtab.tmp"
>> mount: UID:        0
>> mount: eUID:       0
>> mount: spec:  "localhost:/local/0/blah"
>> mount: node:  "/mnt/test"
>> mount: types: "nfs"
>> mount: opts:  "nfsvers=4"
>> final mount options: 'nfsvers=4'
>> mount: external mount: argv[0] = "/sbin/mount.nfs"
>> mount: external mount: argv[1] = "localhost:/local/0/blah"
>> mount: external mount: argv[2] = "/mnt/test"
>> mount: external mount: argv[3] = "-v"
>> mount: external mount: argv[4] = "-o"
>> mount: external mount: argv[5] = "rw,nfsvers=4"
>> mount.nfs: timeout set for Mon Nov 17 14:42:17 2014
>> mount.nfs: trying text-based options 'nfsvers=4,addr=127.0.0.1,clientaddr=127.0.0.1'
>> mount.nfs: mount(2): Connection refused
>> mount.nfs: trying text-based options 'nfsvers=4,addr=127.0.0.1,clientaddr=127.0.0.1'
>> mount.nfs: mount(2): Connection refused
>> mount.nfs: trying text-based options 'nfsvers=4,addr=127.0.0.1,clientaddr=127.0.0.1'
>> mount.nfs: mount(2): Connection refused
>> mount.nfs: trying text-based options 'nfsvers=4,addr=127.0.0.1,clientaddr=127.0.0.1'
>> mount.nfs: mount(2): Connection refused
>> mount.nfs: trying text-based options 'nfsvers=4,addr=127.0.0.1,clientaddr=127.0.0.1'
>> mount.nfs: mount(2): Connection refused
>>
>>
>> Thoughts?
> Have you tried using the -o timeo=1,retry=0 mount options? They might help...
>
But do you really want to have all your other mounts doing this too?

I don't think so, its less resilient right.

I think the /etc/nfsmount.conf fix

[ Server "localhost" ]
     Nfsvers=3


Is 100% sufficient, but it still would be nice to have this brought up 
to your attention easier through error handling/logging.

Unless in automount configuration you could force nfsv4 to do -o 
timeo=1,retry=0 just for localhost then fallback to nfsv3 with different 
set of options.

But I believe you would then globally being setting nfsv4 to use the 
same -o timeo=1,retry=0 options and I don't think there is fallback 
mechanism either.

So basically I still think to have these mounts land you still want the 
previously document solution.

/etc/nfsmount.conf fix

[ Server "localhost" ]
     Nfsvers=3

Thoughts?

> steved.
>


-- 

===================================================================
Dave Sullivan RHCE 			Email: dsulliva@redhat.com
Sr. Technical Account Manager 	

+1 312 660 3525 (Office)
+1 989 750 8385 (Cell)
===================================================================
Red Hat, Inc. | 100 East Davie St | Raleigh, NC | 27601

---
Learn. Network. Experience open source.
http://www.redhat.com
http://access.redhat.com
http://www.opensource.com
