Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([217.72.192.78]:64940 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751766AbdFHIuE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 04:50:04 -0400
MIME-Version: 1.0
Message-ID: <trinity-f2c19596-3afe-4a3f-ad07-78e6cfda9cb5-1496911790012@3capp-webde-bap34>
From: devzero@web.de
To: linux-nfs@vger.kernel.org
Cc: pf@artcom-gmbh.de, rnews@altium.nl, jlayton@redhat.com,
        bfields@fieldses.org
Subject: Re: How to avoid rebooting Linux NFS-client when NFS-server is not
 available?
Content-Type: text/plain; charset=UTF-8
Date: Thu, 8 Jun 2017 10:49:50 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>Indeed: This workaround seems to work!

Unfortunately not in every situation.

We have differnt XEN servers (Citrix XS7) at remote location which have hung/stale NFS mount problems at regular intervals (.ISO storage repo is mounted via WAN) and i always need to reboot, which really really(!) sucks.

At least a fake NFS server as described below releases the stuck mount, i.e. df -h and other processes touching do not hang anymore, so at least this workaround helps to some degree... 

BUT:

# umount /run/sr-mount/2b5c5c60-3744-c860-28a7-eb106d3a339e
umount.nfs: /run/sr-mount/2b5c5c60-3744-c860-28a7-eb106d3a339e: Stale file handle

# mount|grep xen-sr-iso
172.16.28.10:/mnt/S2V2/xen-sr-iso on /run/sr-mount/2b5c5c60-3744-c860-28a7-eb106d3a339e type nfs (rw,relatime,vers=3,rsize=131072,wsize=131072,namlen=255,acdirmin=0,acdirmax=0,soft,proto=tcp,timeo=600,retrans=2147483647,sec=sys,mountaddr=172.16.28.10,mountvers=3,mountport=680,mountproto=tcp,local_lock=none,addr=172.16.28.10)

# umount -l -f /run/sr-mount/2b5c5c60-3744-c860-28a7-eb106d3a339e
umount.nfs: /run/sr-mount/2b5c5c60-3744-c860-28a7-eb106d3a339e: Stale file handle

# mount|grep xen-sr-iso
172.16.28.10:/mnt/S2V2/xen-sr-iso on /run/sr-mount/2b5c5c60-3744-c860-28a7-eb106d3a339e type nfs (rw,relatime,vers=3,rsize=131072,wsize=131072,namlen=255,acdirmin=0,acdirmax=0,soft,proto=tcp,timeo=600,retrans=2147483647,sec=sys,mountaddr=172.16.28.10,mountvers=3,mountport=680,mountproto=tcp,local_lock=none,addr=172.16.28.10)

# ls -la
ls: cannot access 2b5c5c60-3744-c860-28a7-eb106d3a339e: Stale file handle
total 0
drwx------  3 root root   60 Feb 18 17:43 .
drwxr-xr-x 36 root root 1660 Jun  7 18:45 ..
d?????????  ? ?    ?       ?            ? 2b5c5c60-3744-c860-28a7-eb106d3a339e

Any hint on how to circumvent rebooting to remount the nfs share or proactively avoid stale NFS mounts would be very appreciated. (disabling NFS by module unload/load is no option, as our XEN servers do have other NFS mounts for shared storage)

regards
Roland

ps:
I`m not sure if linux-nfs ML will allow anonymous posts (probably not), so maybe someone subscribed be so kind to reply with list cc´ed. I`d like to avoid subscribing to a list because of a single post...




>List:       linux-nfs
>Subject:    Re: How to avoid rebooting Linux NFS-client when NFS-server is not available?
>From:       Peter Funk <pf () artcom-gmbh ! de>
>Date:       2013-07-26 12:08:49
>Message-ID: 20130726120849.GA12584 () pfmaster
>[Download message RAW]

>Dick Streefland wrote 24.07.2013 13:03:
>> Peter Funk <pf@artcom-gmbh.de> wrote:
>> | We've researched this question for quite a while now and nobody here
>> | found a solution to the following problem:
>> | 
>> |  1: A Linux computer is NFS client of some other Linux NFS server
>> |     and has some active mounts and some processes working with files 
>> |     on that NFS server.  
>> | 
>> |  2: Now the NFS server becomes unavailable and a system administrator 
>> |     wants to clean up the situation on the NFS client computer without 
>> |     having to reboot this client computer.
>> | 
>> | Is this possible?  And if how exactly?
>> 
>> What you could try is temporarily add the IP number of the dead NFS
>> server to another NFS server. The other NFS server should reject any
>> request for the dead mount, and the client can continue with an error.
>
>Indeed: This workaround seems to work!
>
>Assume example: The NFS-server has IP 192.168.123.45 and the client
>has also the nfs-kernel-server package installed and it is running.
>Then this sequence on the client did the trick::
>
>    ifconfig eth0:fakesrv 192.168.123.45 up
>    umount -f -l ....
>    umount -f -l ....
>    ....
>    ifconfig eth0:fakesrv down
>
>Best Regards and many thanks for your suggestion,
>Peter Funk
