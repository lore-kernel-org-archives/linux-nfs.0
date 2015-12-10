Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3.dit.upm.es ([138.4.2.18]:57875 "EHLO mail3.dit.upm.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbbLJKc7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Dec 2015 05:32:59 -0500
Subject: Re: possible bug in nfs-kernel-server
To: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <564EFE51.90105@dit.upm.es>
 <20151121091824.71ab1f6b@tlielax.poochiereds.net>
 <b259acd35a93bd2293630c35b8761e6b@dit.upm.es>
Cc: linux-nfs@vger.kernel.org,
        =?UTF-8?Q?administraci=c3=b3n_del_centro_de_c=c3=a1lculo_del_dit?=
	<cdc@dit.upm.es>
From: Omar Walid Llorente <omar@dit.upm.es>
Message-ID: <566954D6.7090508@dit.upm.es>
Date: Thu, 10 Dec 2015 11:32:54 +0100
MIME-Version: 1.0
In-Reply-To: <b259acd35a93bd2293630c35b8761e6b@dit.upm.es>
Content-Type: multipart/mixed;
 boundary="------------050607020801040201020707"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050607020801040201020707
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit


Hi, Jeff, Bruce, finally I got some time to get the capture of the nfs 
packets (you can find them in attached file nfs-problem-nks.pcap.zip). 
Sorry for being so late.

What I did was the following:

1st) Create the RO file:
cdc@l056:~/prueba-git$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt; 
chmod 444 444.txt;

2nd) Init the capture:
root@l056:~# tcpdump -i eth2 -w /tmp/nfs.pcap -s 512 port 2049
tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size 
512 bytes

3rd) Try to copy the RO file and get the error:
cdc@l056:~/prueba-git$ cp -p 444.txt kk.txt;
cp: failed to close ‘kk.txt’: Permission denied
cdc@l056:~/prueba-git$

4th) Close the capture:
^C26 packets captured
26 packets received by filter
0 packets dropped by kernel
root@l056:~#

Hope you can send us some clue about it. Do you need me to do any other 
test? Thanks in advance!

Omar

El 25/11/15 a las 14:50, omar escribió:
>
>
> Hi, Jeff, thanks for the answer. I'm out of the office until next 
> week, but when I come back, I'll try to do the tests and send you the 
> info.
>
> Thank you very much,
>
> Omar
>
> El 2015-11-21 14:18, Jeff Layton escribió:
>> On Fri, 20 Nov 2015 12:04:49 +0100
>> Omar Walid Llorente <omar@dit.upm.es> wrote:
>>
>>>
>>> Hi, I'm Omar Walid Llorente and I am a systems administrator at the
>>> Politechnical University of Madrid (UPM), Spain. I write you in the 
>>> hope
>>> you can help us manage a problem that have discovered recently about 
>>> our
>>> new datastore architecture in our teaching labs. We have created a
>>> gluster distributed volume that we reexport with NFS to our lab clients
>>> via intermediate servers.
>>>
>>> First of all thanks for all your work and sorry if this isn't related
>>> with your package, but I think it has a good chance. I'll try explain
>>> myself as short as possible.
>>>
>>> As introduced previously, we have a problem exporting with
>>> nfs-kernel-server-1.2.8-6 (ubuntu based) a directory previously mounted
>>> with gluster-3.7.4 via fuse mount.
>>>
>>
>> What's important here (for the nfs server) is the kernel version. What
>> kernel version are you running on the server? Also, what NFS version is
>> the client using? If you grab the mount's line out of /proc/mounts on
>> the client then that would be helpful.
>>
>> Also, does the NFS version matter here? If you're using NFSv4 then
>> maybe try with NFSv3, or with v4 or so if you're already using v3?
>>
>>> The problem is quite simple to reproduce and always repeatable: if a
>>> file has read-only permissions for owner and user wants to copy it,
>>> permissions problem arises:
>>> cdc@client:~$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt; chmod 444
>>> 444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
>>> cp: failed to close ‘kk.txt’: Permission denied
>>> -r--r--r-- 1 cdc admincdc 7 nov  3  2015 444.txt
>>> -r--r--r-- 1 cdc admincdc 0 nov  3  2015 kk.txt
>>> cdc@client:~$
>>>
>>> If the file permissions are not read-only, there is no problem:
>>> cdc@client:~$ rm -f kk.txt 644.txt; echo "prueba" > 644.txt; chmod 644
>>> 644.txt; cp -p 644.txt kk.txt; ls -ld 644.txt kk.txt
>>> -rw-r--r-- 1 cdc admincdc 7 nov  3  2015 644.txt
>>> -rw-r--r-- 1 cdc admincdc 7 nov  3  2015 kk.txt
>>> cdc@client:~$
>>>
>>> If we track it down with strace, the problem arises exactly when 
>>> fsync()
>>> is called from cp.
>>>
>>> Of course, if we try this combination of commands in other directories
>>> not mounted by nfs (local ones) or mounted with samba/cifs or even
>>> mounted with nfs-ganesha (both fuse mounted with gluster), this doen't
>>> happen. This problem doesn't happen either if the nfs-kernel-server
>>> exports a directory not mounted with fuse (any local one).
>>>
>>
>> Ok, that's good info, but when dealing with a problem like this, it'd
>> be best to get a capture of the network traffic between client and
>> server while you're reproducing this. We can then look at it to figure
>> out which RPC call is getting the actual error. That will help narrow
>> down the problem a bit more.
>>
>> You can do that with tcpdump. Something like this should do it:
>>
>>     # tcpdump -i eth0 -w /tmp/nfs.pcap -s 512 port 2049
>>
>> ...reproduce the problem and then stop the capture. Then you can
>> open /tmp/nfs.pcap with wireshark to analyze it (or send it to me and
>> I'll take a look).
>>
>>> Please, tell me if this is the right place to post the probem and
>>> where is it if this is not. Let me know if we can help you any way to
>>> solve or test it (we've developed a small program in c that shows
>>> exactly the same behaviour).
>>>
>>> Thanks again.
>>>
>>> Omar
>>>
>>> PS: Pointer to this email address came from:
>>> http://wiki.linux-nfs.org/wiki/index.php/Reporting_bugs
>>>
>>> ADDITIONAL INFO:
>>>
>>> cdc@client:~$ uname -a
>>> Linux l056 3.13.0-63-generic #103-Ubuntu SMP Fri Aug 14 21:43:30 UTC
>>> 2015 i686 i686 i686 GNU/Linux
>>> cdc@client:~$
>>> cdc@client:~$ mount | grep home
>>> cuentas02:/home-3/cdc on /home/cdc type nfs
>>>
>>> (rw,noatime,intr,fsc,nolock,rsize=262140,wsize=262140,addr=138.4.30.15)
>>> cdc@client:~$
>>>
>>> root@server-lab:~# uname -a
>>> Linux cuentas02-lab.lab.dit.upm.es 3.13.0-63-generic #103-Ubuntu SMP
>>> Fri Aug 14 21:42:59 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
>>> root@server-lab:~#
>>> root@server-lab:~# dpkg -l | grep nfs
>>> ii  libnfsidmap2:amd64 0.25-5                           amd64
>>> NFS idmapping library
>>> ii  nfs-common 1:1.2.8-6ubuntu1.1               amd64 NFS
>>> support files common to client and server
>>> ii  nfs-kernel-server 1:1.2.8-6ubuntu1.1               amd64
>>> support for NFS kernel server
>>> root@server-lab:~#
>>> root@server-lab:~# exportfs -v
>>> /home-3
>>>
>>> 138.4.30.0/23(rw,async,wdelay,insecure,no_root_squash,no_subtree_check,fsid=3,sec=sys,rw,no_root_squash,no_all_squash) 
>>>
>>> root@server-lab:~#
>>>
>>> LOGS ON SERVER SIDE (glusterfs mount logs):
>>> [2015-11-20 10:51:53.872656] I [io-stats.c:1014:io_stats_dump_fd]
>>> 0-home-lab-3: --- fd stats ---
>>> [2015-11-20 10:51:53.872692] I [io-stats.c:1019:io_stats_dump_fd]
>>> 0-home-lab-3:       Filename : /cdc/444.txt
>>> [2015-11-20 10:51:53.872704] I [io-stats.c:1034:io_stats_dump_fd]
>>> 0-home-lab-3:   BytesWritten : 7 bytes
>>> [2015-11-20 10:51:53.872714] I [io-stats.c:1046:io_stats_dump_fd]
>>> 0-home-lab-3: Write 000004b+ : 1
>>> [2015-11-20 10:51:53.874917] W [MSGID: 114031]
>>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>>> 0-home-lab-3-client-0: remote operation failed [Permission denied]
>>> [2015-11-20 10:51:53.874976] W [fuse-bridge.c:1230:fuse_err_cbk]
>>> 0-glusterfs-fuse: 63459954: REMOVEXATTR() /cdc/444.txt => -1
>>> (Permission denied)
>>> [2015-11-20 10:51:53.881389] W [MSGID: 114031]
>>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>>> [2015-11-20 10:51:53.881434] W [fuse-bridge.c:1230:fuse_err_cbk]
>>> 0-glusterfs-fuse: 63459961: REMOVEXATTR() /cdc/kk.txt => -1
>>> (Permission denied)
>>> [2015-11-20 10:51:53.883072] W [fuse-bridge.c:1230:fuse_err_cbk]
>>> 0-glusterfs-fuse: 63459964: REMOVEXATTR() /cdc/kk.txt => -1
>>> (Permission denied)
>>> [2015-11-20 10:51:53.883057] W [MSGID: 114031]
>>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>>> [2015-11-20 10:51:53.884003] E [MSGID: 114031]
>>> [client-rpc-fops.c:466:client3_3_open_cbk] 0-home-lab-3-client-3:
>>> remote operation failed. Path: /cdc/kk.txt
>>> (3175e0cd-8308-45b8-a4b0-699f6f8cf37f) [Permission denied]
>>> [2015-11-20 10:51:53.884056] W [fuse-bridge.c:969:fuse_fd_cbk]
>>> 0-glusterfs-fuse: 63459965: OPEN() /cdc/kk.txt => -1 (Permission
>>> denied)
>>
>> The above message is interesting and might be related to the problem.
>> That said, we generally set the NFSD_MAY_OWNER_OVERRIDE bit on opens of
>> regular files, which allows the nfsd_permission check to pass
>> regardless when the owner matches.
>>
>> My guess would be that the dentry_open call in nfsd_open is failing
>> here as the concept of "owner override" doesn't really get passed down
>> to it. Still, it'd be good to confirm that...
>>
>>> [2015-11-20 10:51:53.885619] W [MSGID: 114031]
>>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>>> [2015-11-20 10:51:53.885664] W [fuse-bridge.c:1230:fuse_err_cbk]
>>> 0-glusterfs-fuse: 63459967: REMOVEXATTR() /cdc/kk.txt => -1 (Permission
>>> denied)
>>> [2015-11-20 10:51:53.887908] W [fuse-bridge.c:1230:fuse_err_cbk]
>>> 0-glusterfs-fuse: 63459971: REMOVEXATTR() /cdc/kk.txt => -1 (Permission
>>> denied)
>>> [2015-11-20 10:51:53.887891] W [MSGID: 114031]
>>> [client-rpc-fops.c:1298:client3_3_removexattr_cbk]
>>> 0-home-lab-3-client-3: remote operation failed [Permission denied]
>>>
>>> (NOTE: We have more gluster brick logs but we don't know if are 
>>> relevant)
>>>

-- 
----------------------------------------------------------------
Centro de Cálculo         Depto. Ingeniería Sistemas Telemáticos
E-mail: omar@dit.upm.es        Universidad Politécnica de Madrid
Fax:(+34) 913367333                 E.T.S. Ing. Telecomunicación
Tel:(+34) 915495700-Ext.3005                28040 Madrid (Spain)
Tel:(+34) 915495762-Ext.3005
Tel:(+34) 913367366-Ext.3005
----------------------------------------------------------------


--------------050607020801040201020707
Content-Type: application/zip;
 name="nfs-problem-nks.pcap.zip"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="nfs-problem-nks.pcap.zip"

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
--------------050607020801040201020707--
