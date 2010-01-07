From: Scott Sturdivant <scott-ILTxhEaIe5LR7s880joybQ@public.gmane.org>
Subject: Re: NFS Server Not Responding after hw change (svc: transport	busy,
 not enqueued)
Date: Wed, 6 Jan 2010 20:02:14 -0500 (EST)
Message-ID: <alpine.DEB.1.10.1001061958560.22025@asgard.binrock.net>
References: <alpine.DEB.1.10.1001052221550.22025@asgard.binrock.net> <20100106204017.GN6612@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.binrock.net ([64.34.170.100]:55941 "EHLO binrock.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932644Ab0AGBCT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 20:02:19 -0500
In-Reply-To: <20100106204017.GN6612@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Wed, 6 Jan 2010, J. Bruce Fields wrote:

> On Tue, Jan 05, 2010 at 10:25:34PM -0500, Scott Sturdivant wrote:
>> I'm not sure what level of detail is appropriate here, so I apologize in
>> advance.
>>
>> This past weekend I swapped some hardware on my NFS server.  I swapped in
>> a new motherboard, processor, ram, and am now using the on-board LAN.  My
>> hard drives did not change, and upon booting up everything seemed to be
>> working just fine.  The problems start coming when my clients mount a
>> share and attempt to access a file.  The server is running Ubuntu 9.10
>> 32-bit server edition.  Uname -a: Linux blargh-server
>> 2.6.31-16-generic-pae #53-Ubuntu SMP Tue Dec 8 05:20:21 UTC 2009 i686
>> GNU/Linux The 1:1.2.0-2ubuntu8 nfs-kernel-server package is installed.
>
> On a quick skim I don't see an obvious reason; one approach (if you're
> *positive* there weren't also any software changes) might be just to try
> swapping the hardware back (starting with the LAN?) and see if you can
> reliably turn the problem on/off with just one hardware change.
>
> --b.

Thank you for the good suggestion! I have done this and have verified that 
indeed the onboard LAN is the root of the problem.  However, as the 
onboard LAN is able to handle Samba / scp but fails with NFS, I'm curious 
if this is an actual hardware problem or a driver issue?  Does anyone know 
where the appropriate place for this problem would be?  Is there an atl1c 
list?

Thanks again,

Scott

>> On the clients, I can mount the shares with "mount -t nfs
>> file-server:/home/scott/Videos/ ~/Videos".  The server's dmesg shows "Jan
>> 5 07:49:23 file-server mountd[1606]: authenticated mount request from
>> 192.168.1.100:802 for /home/scott/Videos/ (/home/scott/Videos/)" I can
>> then "ls" that directory and retrieve the directory listing.  But if I
>> access a file (cp ~/Videos/*.avi /tmp), only a portion of a single file
>> copies before the I/O will be blocked.  Eventually dmesg on the client
>> will give the following error:  nfs: server file-server not responding,
>> still trying
>>
>> At this point, executing 'rpcinfo -p file-server' from the client still
>> seems to indicate that NFS is running just fine on the server.
>>
>> (scott) file-client:~
>> 507 -> rpcinfo -p file-server
>>    program vers proto   port
>>     100000    2   tcp    111  portmapper
>>     100000    2   udp    111  portmapper
>>     100024    1   udp  41238  status
>>     100024    1   tcp  55833  status
>>     100021    1   udp  38360  nlockmgr
>>     100021    3   udp  38360  nlockmgr
>>     100021    4   udp  38360  nlockmgr
>>     100021    1   tcp  59774  nlockmgr
>>     100021    3   tcp  59774  nlockmgr
>>     100021    4   tcp  59774  nlockmgr
>>     100003    2   udp   2049  nfs
>>     100003    3   udp   2049  nfs
>>     100003    4   udp   2049  nfs
>>     100003    2   tcp   2049  nfs
>>     100003    3   tcp   2049  nfs
>>     100003    4   tcp   2049  nfs
>>     100005    1   udp  42451  mountd
>>     100005    1   tcp  57648  mountd
>>     100005    2   udp  42451  mountd
>>     100005    2   tcp  57648  mountd
>>     100005    3   udp  42451  mountd
>>     100005    3   tcp  57648  mountd
>>
>> As you can see though, the I/O is blocked.
>>
>> (scott) file-client:~
>> 504 -> ps aux | grep " D"
>> scott     4405  0.0  0.0   3428   920 pts/1    D+   08:04   0:00 cp
>> Videos/*.avi /tmp/
>>
>> On the server's end, I do not see any errors in dmesg or syslog or
>> messages.  That is until I increased the logging level using rpcdebug.
>> (Now I'm not sure if I did this correctly, but I did 'rpcdebug -m module
>> -s all' for all of the modules listed by rpcdebug -vh).
>>
>> In the below snippet from the server's dmesg, there are many svc:
>> transport %p busy, not enqueued messages:
>>
>> [ 6588.481185] nfsd_dispatch: vers 3 proc 6
>> [ 6588.481211] nfsd: READ(3) 36: 01070001 0141401d 00000000 e12f98aa
>> 1c4965f0 0d4e5b93 131072 bytes at 22282240
>> [ 6588.481231] nfsd: fh_verify(36: 01070001 0141401d 00000000 e12f98aa
>> 1c4965f0 0d4e5b93)
>> [ 6588.481747] svc: socket f45f8e00 sendto([ed215000 132... ], 131204) =
>> 131204 (addr 192.168.1.100, port=915)
>> [ 6588.481776] svc: socket f45f8e00 recvfrom(f45f8f70, 0) = 4
>> [ 6588.481792] svc: TCP record, 156 bytes
>> [ 6588.481821] svc: server f6ccd000 waiting for data (to = 900000)
>> [ 6588.482701] svc: socket f45f8e00 sendto([ea53a000 132... ], 131204) =
>> 131204 (addr 192.168.1.100, port=915)
>> [ 6588.482727] svc: socket f45f8e00 recvfrom(c7ab109c, 3940) = 156
>> [ 6588.482732] svc: TCP complete record (156 bytes)
>> [ 6588.482739] svc: transport f45f8e00 served by daemon f6ccd000
>> [ 6588.482752] svc: transport f45f8e00 busy, not enqueued
>> [ 6588.482766] svc: got len=156
>> [ 6588.482781] svc: server f6cca000 waiting for data (to = 900000)
>> [ 6588.482787] svc: svc_authenticate (1)
>> [ 6588.482798] svc: calling dispatcher
>> [ 6588.482806] nfsd_dispatch: vers 3 proc 6
>> [ 6588.482831] nfsd: READ(3) 36: 01070001 0141401d 00000000 e12f98aa
>> 1c4965f0 0d4e5b93 131072 bytes at 22151168
>> [ 6588.482854] svc: transport f45f8e00 busy, not enqueued
>> [ 6588.482870] nfsd: fh_verify(36: 01070001 0141401d 00000000 e12f98aa
>> 1c4965f0 0d4e5b93)
>> [ 6588.483499] svc: socket f45f8e00 sendto([cddbc000 132... ], 131204) =
>> 131204 (addr 192.168.1.100, port=915)
>> [ 6588.483531] svc: transport f45f8e00 busy, not enqueued
>> [ 6588.483543] svc: server de5f6000 waiting for data (to = 900000)
>> [ 6588.483639] svc: socket f45f8e00 sendto([f4dbd000 132... ], 131204) =
>> 131204 (addr 192.168.1.100, port=915)
>> [ 6588.483667] svc: transport f45f8e00 busy, not enqueued
>> [ 6588.483674] svc: server f45d4000 waiting for data (to = 900000)
>> [ 6588.483904] svc: socket f45f8e00 sendto([ea445000 132... ], 131204) =
>> 131204 (addr 192.168.1.100, port=915)
>> [ 6588.483931] svc: transport f45f8e00 busy, not enqueued
>> [ 6588.483937] svc: server de5f0000 waiting for data (to = 900000)
>> [ 6588.483987] svc: server f6ccd000, pool 0, transport f45f8e00, inuse=2
>> [ 6588.484004] svc: tcp_recv f45f8e00 data 1 conn 0 close 0
>> [ 6588.484018] svc: socket f45f8e00 recvfrom(f45f8f70, 0) = 4
>> [ 6588.484023] svc: TCP record, 156 bytes
>> [ 6588.484036] svc: socket f45f8e00 recvfrom(cdc2f09c, 3940) = 156
>>
>> While I'm obviously suspect of the hardware being as that's what changed,
>> I can ssh to the server, scp large files between the two, and I can samba
>> share the same directories without any problems.  On the server I can
>> even mount an NFS share locally and manipulate the files just fine.  NFS
>> over the network seems to be the only thing giving me problems.
>>
>> Thanks for any help, and please let me know if there's more detail that I
>> can add to assist debugging.
>>
>> Scott
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
