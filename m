Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753301AbbLJM3h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Dec 2015 07:29:37 -0500
Subject: Re: possible bug in nfs-kernel-server
To: Omar Walid Llorente <omar@dit.upm.es>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <564EFE51.90105@dit.upm.es>
 <20151121091824.71ab1f6b@tlielax.poochiereds.net>
 <b259acd35a93bd2293630c35b8761e6b@dit.upm.es> <566954D6.7090508@dit.upm.es>
Cc: linux-nfs@vger.kernel.org,
        =?UTF-8?Q?administraci=c3=b3n_del_centro_de_c=c3=a1lculo_del_dit?=
	<cdc@dit.upm.es>
From: Soumya Koduri <skoduri@redhat.com>
Message-ID: <5669702D.50402@redhat.com>
Date: Thu, 10 Dec 2015 17:59:33 +0530
MIME-Version: 1.0
In-Reply-To: <566954D6.7090508@dit.upm.es>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/10/2015 04:02 PM, Omar Walid Llorente wrote:
>
> Hi, Jeff, Bruce, finally I got some time to get the capture of the nfs
> packets (you can find them in attached file nfs-problem-nks.pcap.zip).
> Sorry for being so late.
>
> What I did was the following:
>
> 1st) Create the RO file:
> cdc@l056:~/prueba-git$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt;
> chmod 444 444.txt;
>
> 2nd) Init the capture:
> root@l056:~# tcpdump -i eth2 -w /tmp/nfs.pcap -s 512 port 2049
> tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size
> 512 bytes
>
GlusterFS protocol is added to wireshark from version 1.8.0 [1]. It may 
be helpful to see what GlusterFS operations are being processed as part 
of NFS WRITE call (which has failed in this case).

Could you please try taking the packet trace on the machine where NFS 
server is running (without filtering out based on the port number).

Also I tried out the same test on Fedora22 machine, but haven't run into 
any issue. What are the fuse mount options you have used to mount 
gluster volume?

Thanks,
Soumya

[1] https://www.wireshark.org/docs/dfref/g/glusterfs.html

> 3rd) Try to copy the RO file and get the error:
> cdc@l056:~/prueba-git$ cp -p 444.txt kk.txt;
> cp: failed to close ‘kk.txt’: Permission denied
> cdc@l056:~/prueba-git$
>
> 4th) Close the capture:
> ^C26 packets captured
> 26 packets received by filter
> 0 packets dropped by kernel
> root@l056:~#
>
> Hope you can send us some clue about it. Do you need me to do any other
> test? Thanks in advance!
>
> Omar
>
> El 25/11/15 a las 14:50, omar escribió:
>>
>>
>> Hi, Jeff, thanks for the answer. I'm out of the office until next
>> week, but when I come back, I'll try to do the tests and send you the
>> info.
>>
>> Thank you very much,
>>
>> Omar
>>
>> El 2015-11-21 14:18, Jeff Layton escribió:
>>> On Fri, 20 Nov 2015 12:04:49 +0100
>>> Omar Walid Llorente <omar@dit.upm.es> wrote:
>>>
>>>>
>>>> Hi, I'm Omar Walid Llorente and I am a systems administrator at the
>>>> Politechnical University of Madrid (UPM), Spain. I write you in the
>>>> hope
>>>> you can help us manage a problem that have discovered recently about
>>>> our
>>>> new datastore architecture in our teaching labs. We have created a
>>>> gluster distributed volume that we reexport with NFS to our lab clients
>>>> via intermediate servers.
>>>>
>>>> First of all thanks for all your work and sorry if this isn't related
>>>> with your package, but I think it has a good chance. I'll try explain
>>>> myself as short as possible.
>>>>
>>>> As introduced previously, we have a problem exporting with
>>>> nfs-kernel-server-1.2.8-6 (ubuntu based) a directory previously mounted
>>>> with gluster-3.7.4 via fuse mount.
>>>>
>>>
>>> What's important here (for the nfs server) is the kernel version. What
>>> kernel version are you running on the server? Also, what NFS version is
>>> the client using? If you grab the mount's line out of /proc/mounts on
>>> the client then that would be helpful.
>>>
>>> Also, does the NFS version matter here? If you're using NFSv4 then
>>> maybe try with NFSv3, or with v4 or so if you're already using v3?
>>>
>>>> The problem is quite simple to reproduce and always repeatable: if a
>>>> file has read-only permissions for owner and user wants to copy it,
>>>> permissions problem arises:
>>>> cdc@client:~$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt; chmod 444
>>>> 444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
>>>> cp: failed to close ‘kk.txt’: Permission denied
>>>> -r--r--r-- 1 cdc admincdc 7 nov  3  2015 444.txt
>>>> -r--r--r-- 1 cdc admincdc 0 nov  3  2015 kk.txt
>>>> cdc@client:~$
>>>>
>>>> If the file permissions are not read-only, there is no problem:
>>>> cdc@client:~$ rm -f kk.txt 644.txt; echo "prueba" > 644.txt; chmod 644
>>>> 644.txt; cp -p 644.txt kk.txt; ls -ld 644.txt kk.txt
>>>> -rw-r--r-- 1 cdc admincdc 7 nov  3  2015 644.txt
>>>> -rw-r--r-- 1 cdc admincdc 7 nov  3  2015 kk.txt
>>>> cdc@client:~$
>>>>
>>>> If we track it down with strace, the problem arises exactly when
>>>> fsync()
>>>> is called from cp.
>>>>
>>>> Of course, if we try this combination of commands in other directories
>>>> not mounted by nfs (local ones) or mounted with samba/cifs or even
>>>> mounted with nfs-ganesha (both fuse mounted with gluster), this doen't
>>>> happen. This problem doesn't happen either if the nfs-kernel-server
>>>> exports a directory not mounted with fuse (any local one).
>>>>
>>>
>>> Ok, that's good info, but when dealing with a problem like this, it'd
>>> be best to get a capture of the network traffic between client and
>>> server while you're reproducing this. We can then look at it to figure
>>> out which RPC call is getting the actual error. That will help narrow
>>> down the problem a bit more.
>>>
>>> You can do that with tcpdump. Something like this should do it:
>>>
>>>     # tcpdump -i eth0 -w /tmp/nfs.pcap -s 512 port 2049
>>>
>>> ...reproduce the problem and then stop the capture. Then you can
>>> open /tmp/nfs.pcap with wireshark to analyze it (or send it to me and
>>> I'll take a look).
>>>
>>>> Please, tell me if this is the right place to post the probem and
>>>> where is it if this is not. Let me know if we can help you any way to
>>>> solve or test it (we've developed a small program in c that shows
>>>> exactly the same behaviour).
>>>>
>>>> Thanks again.
>>>>
>>>> Omar
>>>>
>>>> PS: Pointer to this email address came from:
>>>> http://wiki.linux-nfs.org/wiki/index.php/Reporting_bugs
>>>>
>>>> ADDITIONAL INFO:
>>>>
>>>> cdc@client:~$ uname -a
>>>> Linux l056 3.13.0-63-generic #103-Ubuntu SMP Fri Aug 14 21:43:30 UTC
>>>> 2015 i686 i686 i686 GNU/Linux
>>>> cdc@client:~$
>>>> cdc@client:~$ mount | grep home
>>>> cuentas02:/home-3/cdc on /home/cdc type nfs
>>>>
>>>> (rw,noatime,intr,fsc,nolock,rsize=262140,wsize=262140,addr=138.4.30.15)
>>>> cdc@client:~$
>>>>
>>>> root@server-lab:~# uname -a
>>>> Linux cuentas02-lab.lab.dit.upm.es 3.13.0-63-generic #103-Ubuntu SMP
>>>> Fri Aug 14 21:42:59 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
>>>> root@server-lab:~#
>>>> root@server-lab:~# dpkg -l | grep nfs
>>>> ii  libnfsidmap2:amd64 0.25-5                           amd64
>>>> NFS idmapping library
>>>> ii  nfs-common 1:1.2.8-6ubuntu1.1               amd64 NFS
>>>> support files common to client and server
>>>> ii  nfs-kernel-server 1:1.2.8-6ubuntu1.1               amd64
>>>> support for NFS kernel server
>>>> root@server-lab:~#
>>>> root@server-lab:~# exportfs -v
>>>> /home-3
>>>>
>>>> 138.4.30.0/23(rw,async,wdelay,insecure,no_root_squash,no_subtree_check,fsid=3,sec=sys,rw,no_root_squash,no_all_squash)
>>>>
>>>> root@server-lab:~#
>>>>
>>>> LOGS ON SERVER SIDE (glusterfs mount logs):
>>>> [2015-11-20 10:51:53.872656] I [io-stats.c:1014:io_stats_dump_fd]
>>>> 0-home-lab-3: --- fd stats ---
>>>> [2015-11-20 10:51:53.872692] I [io-stats.c:1019:io_stats_dump_fd]
>>>> 0-home-lab-3:       Filename : /cdc/444.txt
>>>> [2015-11-20 10:51:53.872704] I [io-stats.c:1034:io_stats_dump_fd]
>>>> 0-home-lab-3:   BytesWritten : 7 bytes
>>>> [2015-11-20 10:51:53.872714] I [io-stats.c:1046:io_stats_dump_fd]
>>>> 0-home-lab-3: Write 000004b+ : 1
>>>> [2015-11-20 10:51:53.874917] W [MSGID: 114031]
>>>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>>>> 0-home-lab-3-client-0: remote operation failed [Permission denied]
>>>> [2015-11-20 10:51:53.874976] W [fuse-bridge.c:1230:fuse_err_cbk]
>>>> 0-glusterfs-fuse: 63459954: REMOVEXATTR() /cdc/444.txt => -1
>>>> (Permission denied)
>>>> [2015-11-20 10:51:53.881389] W [MSGID: 114031]
>>>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>>>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>>>> [2015-11-20 10:51:53.881434] W [fuse-bridge.c:1230:fuse_err_cbk]
>>>> 0-glusterfs-fuse: 63459961: REMOVEXATTR() /cdc/kk.txt => -1
>>>> (Permission denied)
>>>> [2015-11-20 10:51:53.883072] W [fuse-bridge.c:1230:fuse_err_cbk]
>>>> 0-glusterfs-fuse: 63459964: REMOVEXATTR() /cdc/kk.txt => -1
>>>> (Permission denied)
>>>> [2015-11-20 10:51:53.883057] W [MSGID: 114031]
>>>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>>>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>>>> [2015-11-20 10:51:53.884003] E [MSGID: 114031]
>>>> [client-rpc-fops.c:466:client3_3_open_cbk] 0-home-lab-3-client-3:
>>>> remote operation failed. Path: /cdc/kk.txt
>>>> (3175e0cd-8308-45b8-a4b0-699f6f8cf37f) [Permission denied]
>>>> [2015-11-20 10:51:53.884056] W [fuse-bridge.c:969:fuse_fd_cbk]
>>>> 0-glusterfs-fuse: 63459965: OPEN() /cdc/kk.txt => -1 (Permission
>>>> denied)
>>>
>>> The above message is interesting and might be related to the problem.
>>> That said, we generally set the NFSD_MAY_OWNER_OVERRIDE bit on opens of
>>> regular files, which allows the nfsd_permission check to pass
>>> regardless when the owner matches.
>>>
>>> My guess would be that the dentry_open call in nfsd_open is failing
>>> here as the concept of "owner override" doesn't really get passed down
>>> to it. Still, it'd be good to confirm that...
>>>
>>>> [2015-11-20 10:51:53.885619] W [MSGID: 114031]
>>>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>>>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>>>> [2015-11-20 10:51:53.885664] W [fuse-bridge.c:1230:fuse_err_cbk]
>>>> 0-glusterfs-fuse: 63459967: REMOVEXATTR() /cdc/kk.txt => -1 (Permission
>>>> denied)
>>>> [2015-11-20 10:51:53.887908] W [fuse-bridge.c:1230:fuse_err_cbk]
>>>> 0-glusterfs-fuse: 63459971: REMOVEXATTR() /cdc/kk.txt => -1 (Permission
>>>> denied)
>>>> [2015-11-20 10:51:53.887891] W [MSGID: 114031]
>>>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>>>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>>>>
>>>> (NOTE: We have more gluster brick logs but we don't know if are
>>>> relevant)
>>>>
>
