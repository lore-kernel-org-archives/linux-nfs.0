Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41434 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754029AbcLPPAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Dec 2016 10:00:32 -0500
Date: Fri, 16 Dec 2016 10:00:30 -0500
To: Omar Walid Llorente <omar@dit.upm.es>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: Re: possible bug in nfs-kernel-server
Message-ID: <20161216150030.GA31705@fieldses.org>
References: <b24a534f-60d9-8f07-5bd2-7f34b8c7313f@dit.upm.es>
 <019f8f5c-e1e9-d2ad-c0f0-ca9017c737fc@dit.upm.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <019f8f5c-e1e9-d2ad-c0f0-ca9017c737fc@dit.upm.es>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 16, 2016 at 12:49:27PM +0100, Omar Walid Llorente wrote:
> Thanks Bruce, and all.
> 
> Sorry about the bug report. I think I will have nightmares about this ;-(
> 
> I have tried to fix the explanation with the following message and
> hope it is not a misleading one:
> 
> Sorry to all, I have to apologize because I tried to super-simplify the problem in the explanation without remembering properly previous tests made and possible issues discarded...
> 
> The origin of this problem is about copying a read-only file, not about writing data on it.
> 
> Tell me if you think maybe is better to file a new bug or to explain it again in this bug report.

Adding a comment sounds fine, thanks.

--b.

> 
> If the later, the explanation would be the following (based onhttp://marc.info/?l=linux-nfs&m=147932042025835):
> 
> Description of problem:
> When you export a glusterfs fuse-mounted volume through a nfs-kernel-server, if the nfs-client mounting it tries to copy an owned read-only file -not being root user-, a permission denied error shows up at the client side and it is recorded at the glusterfs logs.
> 
> If the user is root no problem exist.
> 
> Version-Release number of selected component (if applicable):
> All versions tested (glusterfs-3.7.{4-16}, glusterfs-3.8.{4-5})
> 
> How reproducible:
> Always
> 
> Steps to Reproduce:
> The setup is:
> 
>       nfs client---NFSv3--->knfsd---FUSE-->gluster
> 
> The tests are:
> 
> # At the knfsd server:
> root@cuentas03-lab:/etc# cat /proc/mounts
> [...]
> recipiente6hd:/home-lab-3.tcp /home-3-old fuse.glusterfs rw,relatime,user_id=0,group_id=0,default_permissions,allow_other,max_read=131072 0 0
> root@cuentas03-lab:/etc#
> 
> # At the nfs-client:
> cdc@l056:~$ cat /proc/mounts | grep "/home/cdc"
> cuentas03:/home-3-old/cdc /home/cdc nfs rw,noatime,vers=3,rsize=131072,wsize=131072,namlen=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=138.4.30.18,mountvers=3,mountport=49531,mountproto=tcp,fsc,local_lock=all,addr=138.4.30.18
> 0 0 cdc@l056:~$ cdc@l056:~$ cdc@l056:~$ cdc@l056:~$ cdc@l056:~$
> cdc@l056:~$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt; chmod 444
> 444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
> cp: failed to close ‘kk.txt’: Permission denied
> -r--r--r-- 1 cdc admincdc 7 nov 16  2016 444.txt
> -r--r--r-- 1 cdc admincdc 0 nov 16  2016 kk.txt
> cdc@l056:~$
> cdc@l056:~$
> cdc@l056:~$
> cdc@l056:~$
> cdc@l056:~$ sudo su
> root@l056:/home/cdc# rm -f kk.txt 444.txt; echo "prueba" > 444.txt; chmod 444 444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
> -r--r--r-- 1 root root 7 nov 16  2016 444.txt
> -r--r--r-- 1 root root 7 nov 16  2016 kk.txt
> root@l056:/home/cdc# exit
> cdc@l056:~$
> 
> Actual results:
> As a nfs-client of a fuse-mounted glusterfs volume, a user who owns a file that is read-only cannot copy it to a new file.
> 
> Expected results:
> As a nfs-client of a fuse-mounted glusterfs volume, a user who owns a file that is read-only should be able to copy it even if it is read-only.
> 
> Hope this helps to clarify. Sorry for the noise.
> 
> El 15/12/16 a las 21:19, J. Bruce Fields escribió:
> >On Thu, Dec 15, 2016 at 08:13:35PM +0000, Brian Cowan wrote:
> >>Guys, pardon me for jumping in, but this isn't a bug... This is
> >>actually how 444 permissions work. You can't *open* a file for write
> >>with 444 permissions.
> >>
> >>This is on an ext4 filesystem: [brian@bullwinkle ~]$ touch foo.txt
> >>[brian@bullwinkle ~]$ chmod 444 foo.txt [brian@bullwinkle ~]$ ls >
> >>foo.txt -bash: foo.txt: Permission denied [brian@bullwinkle ~]$ pwd
> >>/home/brian [brian@bullwinkle ~]$ df -k .  Filesystem
> >>1K-blocks      Used Available Use% Mounted on
> >>/dev/mapper/vg_oc2065315552-lv_root 463406952 266869532 172974568  61%
> >>/ [brian@bullwinkle ~]$ mount | grep root
> >>/dev/mapper/vg_oc2065315552-lv_root on / type ext4
> >>(rw,relatime,seclabel,data=ordered)
> >>
> >>{{{ Yes, I know, shouldn't have my home dir on the root fs, but it's a
> >>test machine...}}}
> >>
> >>This being said, you can CREATE a file with 444 permissions and write
> >>to it -- in the session that created it. I can provide a demo program
> >>that shows that...
> >Yes, I think their reproducer is wrong.  If I recall correctly, the
> >originally reported problem concerned a write open that created a new
> >file.
> >
> >--b.
> >
> >>And root? Well root can do almost anything...
> >>
> >>-- Brian
> >>-----Original Message-----
> >>From:linux-nfs-owner@vger.kernel.org  [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Omar Walid Llorente
> >>Sent: Thursday, December 15, 2016 12:07 PM
> >>To: J. Bruce Fields<bfields@fieldses.org>
> >>Cc: Soumya Koduri<skoduri@redhat.com>; Miklos Szeredi<mszeredi@redhat.com>; Jeff Layton<jlayton@poochiereds.net>;linux-nfs@vger.kernel.org; administracion del centro de calculo del dit<cdc@dit.upm.es>
> >>Subject: Re: possible bug in nfs-kernel-server
> >>
> >>Thanks Bruce, all.
> >>
> >>I just filed a bug in bugzilla.redhat.com.
> >>
> >>Seehttps://bugzilla.redhat.com/show_bug.cgi?id=1405147
> >>
> >>I hope that soon we have this problem solved.
> >>
> >>Omar
> >>
> >>CONTENT of bugzilla bug report:
> >>
> >>Description of problem:
> >>When using a fuse-mounted glusterfs volume, an error is found if the
> >>owner of a file (that is not root) tries to write in its own file when
> >>it has read-only permissions.
> >>
> >>The problem does not exist if the user is root.
> >>
> >>Version-Release number of selected component (if applicable):
> >>All versions tested (glusterfs-3.7.{4-16}, glusterfs-3.8.{4-5})
> >>
> >>How reproducible:
> >>Always
> >>
> >>Steps to Reproduce:
> >>
> >>1. Fuse mount a glusterfs volume to be the home of the user, cd to home
> >>dir and check that the file we will use for testing does not exist:
> >>user@computer:~$ ls -l 444.txt
> >>ls: cannot access 444.txt: No such file or directory
> >>user@computer:~$
> >>
> >>2. Execute command (error comes at echo, not before):
> >>user@computer:~$ rm -f 444.txt; touch 444.txt; chmod 444 444.txt; echo
> >>test > 444.txt
> >>-bash: 444.txt: Permission denied
> >>
> >>3. Check result: File is empty.
> >>user@computer:~$ ls -l 444.txt
> >>-r--r--r-- 1 user user 0 dic 15  2016 444.txt
> >>user@computer:~$ rm -f 444.txt
> >>user@computer:~$
> >>
> >>4. Check that the problem dissapears with root privileges:
> >>user@computer:~$ sudo su
> >>root@computer:/home/user# rm -f 444.txt; touch 444.txt; chmod 444
> >>444.txt; echo test > 444.txt
> >>root@computer:/home/user# ls -l 444.txt
> >>-r--r--r-- 1 root root 5 dic 15  2016 444.txt
> >>root@computer:/home/user# rm -f 444.txt
> >>root@computer:/home/user#
> >>
> >>Actual results:
> >>A user who owns a file that is read-only cannot write into it.
> >>
> >>Expected results:
> >>A user who owns a file that is read-only should be able to write into it
> >>even if it is read-only.
> >>
> >>Additional info:
> >>Special thanks to Bruce Fields and other components of nfs-kernel-server
> >>team because initially we thought it was their fault. The same to Soumya
> >>Koduri and Miklos Szeredi, that helped to confirm the problem.
> >>
> >>See full previous thread on nfs-kernel-server list with history about
> >>the issue:
> >>http://marc.info/?t=144801803400001  (for posterity's sake, permanent
> >>link:http://marc.info/?i=862ef8b0-61ee-8b7e-a81c-fcdc5a726e37@dit.upm.es).
> >>
> >>
> >>El 28/11/16 a las 19:25, J. Bruce Fields escribió:
> >>>On Mon, Nov 28, 2016 at 07:03:48PM +0100, Omar Walid Llorente wrote:
> >>>>Hi Soumya, all.
> >>>>
> >>>>Sorry for the delay answering.
> >>>>
> >>>>Following your sugestion, we are planning to file a bug at bugzilla
> >>>>[1], but in order to minimize the content of the explanation, we
> >>>>wanted to include a link to the file archive of this
> >>>>nfs-kernel-server list, but we only find a page that doesn't work
> >>>>(fromhttp://dir.gmane.org/gmane.linux.nfs  we go to
> >>>>http://news.gmane.org/gmane.linux.nfs, but it gives a "Page Not
> >>>>Found" answer).
> >>>>
> >>>>Does anybody know if is this link available anywhere else or if it
> >>>>can be repaired?
> >>>>
> >>>>Thanks a lot to everyone. We hope we can file the bug this week.
> >>>http://marc.info/?t=144801803400001&r=1&w=2
> >>>
> >>>Or you can link by message id like:
> >>>
> >>>http://marc.info/?i=862ef8b0-61ee-8b7e-a81c-fcdc5a726e37@dit.upm.es
> >>>
> >>>which I sometimes try to for posterity's sake since the message id
> >>>should still be useful even if the one archive dies.
> >>>
> >>>--b.
> >>>
> >>>
> >>>>Omar
> >>>>
> >>>>El 22/11/16 a las 15:45, Soumya Koduri escribió:
> >>>>>On 11/21/2016 08:27 PM, J. Bruce Fields wrote:
> >>>>>>On Mon, Nov 21, 2016 at 06:26:16PM +0530, Soumya Koduri wrote:
> >>>>>>>Hi,
> >>>>>>>
> >>>>>>>Sorry for the delay. I could reproduce the issue on my gluster setup
> >>>>>>>as well. The error is generated at posix-acl xlator layer of
> >>>>>>>glusterfs server.
> >>>>>>>
> >>>>>>>As Bruce mentioned in the earlier mail, as part of WRITE call,
> >>>>>>>NFS-server issues OPEN() with O_WRONLY flag set. Since the
> >>>>>>>attributes of the file "kk.txt" when created was 0400, the
> >>>>>>>corresponding acl maps to below ACL -
> >>>>>>>
> >>>>>>>[root@dhcp35-197 vol1]# getfacl kk.txt
> >>>>>>># file: kk.txt
> >>>>>>># owner: guest
> >>>>>>># group: mock
> >>>>>>>user::r--
> >>>>>>>group::---
> >>>>>>>other::---
> >>>>>>>
> >>>>>>>And hence the permission check for WRITE access fails. Also not just
> >>>>>>>glusterfs, I see similar behavior with ext4 filesystem as well when
> >>>>>>>exported via kernel-NFS server.
> >>>>>>That definitely shouldn't be happening, how are you reproducing?
> >>>>>Sorry. Yesterday when I was testing, both the exports (one on
> >>>>>glusterfs fuse mount and another on ext4) had same fsid. So when I
> >>>>>was trying to mount and access the share on ext4, it had
> >>>>>redirected to glusterfs fuse mount and hence the test failed.
> >>>>>
> >>>>>I re-checked with ext4 and I do not see any failures. So probably
> >>>>>then we need to put a fix in glusterfs to bypass this check for
> >>>>>file owner during OPEN.
> >>>>>
> >>>>>@Omar,
> >>>>>Could you please file a bug against glusterfs component in RH
> >>>>>bugzilla [1] for the same?
> >>>>>
> >>>>>Thanks,
> >>>>>Soumya
> >>>>>
> >>>>>[1]https://bugzilla.redhat.com/enter_bug.cgi?product=GlusterFS
> >>>>>
> >>>>>>--b.
> >>>>>>
> >>>>>>>So I am not sure if fixing glusterfs
> >>>>>>>for this use-case is valid.
> >>>>>>>
> >>>>>>>Thanks,
> >>>>>>>Soumya
> >>>>>>>
> >>>>>>>
> >>>>>>>On 11/18/2016 09:33 PM, Omar Walid Llorente wrote:
> >>>>>>>>Yes, of course,  we can reproduce the problem on latest (e.g
> >>>>>>>>4.8) kernel.
> >>>>>>>>
> >>>>>>>>Tested on a server with fedora 24 (Linux cuentas11.lab.dit.upm.es
> >>>>>>>>4.8.4-200.fc24.x86_64 #1 SMP Tue Oct 25 13:06:04 UTC 2016
> >>>>>>>>x86_64 x86_64
> >>>>>>>>x86_64 GNU/Linux), glusterfs-fuse-3.8.5-1.fc24.x86_64,
> >>>>>>>>fuse-2.9.7-1.fc24.x86_64 and nfs-utils-1.3.4-1.rc2.fc24.x86_64 that
> >>>>>>>>mounts as a glusterfs-client and exports as a nfs-server a ditributed
> >>>>>>>>glusterfs volume (that comes from a 3.7.4 glusterfs server over Ubuntu
> >>>>>>>>14.04.
> >>>>>>>>
> >>>>>>>>[root@cuentas11 ~]# cat /proc/mounts  | grep home
> >>>>>>>>recipiente8hd:/home-lab-3.tcp /home-3 fuse.glusterfs
> >>>>>>>>rw,relatime,user_id=0,group_id=0,default_permissions,allow_other,max_read=131072
> >>>>>>>>
> >>>>>>>>0 0
> >>>>>>>>[root@cuentas11 ~]#
> >>>>>>>>
> >>>>>>>>As you may remember the schema is the one that follows
> >>>>>>>>(glusterfs volume
> >>>>>>>>name: home-lab-3, glusterfs client mount point: /home-3, nfs client
> >>>>>>>>mount point: /home):
> >>>>>>>>
> >>>>>>>>nfs client (v1.2.8) ---> NFSv3 ---> knfsd (v1.3.4 over a Linux v4.8.4
> >>>>>>>>kernel) ---> FUSE (v2.9.7) --> glusterfs client (v3.8.5) --> GLUSTER
> >>>>>>>>over TCP --> glusterfs server (v3.7.4)
> >>>>>>>>
> >>>>>>>>The errors at the nfs-client side are the same:
> >>>>>>>>
> >>>>>>>>cdc@l056:~$ mount | grep "/home/cdc"
> >>>>>>>>cuentas11:/home-3/cdc on /home/cdc type nfs (rw,noatime,nfsvers=3,vers=3,tcp,intr,fsc,nolock,rsize=262140,wsize=262140,addr=138.4.30.86)
> >>>>>>>>cdc@l056:~$ cdc@l056:~$ cdc@l056:~$ cdc@l056:~$ rm
> >>>>>>>>-f kk.txt 444.txt; echo "prueba" > 444.txt; chmod
> >>>>>>>>444
> >>>>>>>>444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
> >>>>>>>>cp: failed to close ‘kk.txt’: Permission denied
> >>>>>>>>-r--r--r-- 1 cdc admincdc 7 nov 18  2016 444.txt
> >>>>>>>>-r--r--r-- 1 cdc admincdc 0 nov 18  2016 kk.txt
> >>>>>>>>cdc@l056:~$
> >>>>>>>>cdc@l056:~$
> >>>>>>>>cdc@l056:~$
> >>>>>>>>cdc@l056:~$ sudo su
> >>>>>>>>[sudo] password for cdc:
> >>>>>>>>root@l056:/home/cdc# rm -f kk.txt 444.txt; echo "prueba" > 444.txt;
> >>>>>>>>chmod 444 444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
> >>>>>>>>-r--r--r-- 1 root root 7 nov 18  2016 444.txt
> >>>>>>>>-r--r--r-- 1 root root 7 nov 18  2016 kk.txt
> >>>>>>>>root@l056:/home/cdc#
> >>>>>>>>root@l056:/home/cdc#
> >>>>>>>>root@l056:/home/cdc# exit
> >>>>>>>>cdc@l056:~$
> >>>>>>>>
> >>>>>>>>See at the end the logs with and without the debug option activated at
> >>>>>>>>the glusterfs client.
> >>>>>>>>
> >>>>>>>>Thanks again, and sorry for the long message.
> >>>>>>>>
> >>>>>>>>Omar
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>* Logs on the glusterfs client side with NO DEBUG:
> >>>>>>>>
> >>>>>>>>[2016-11-18 15:45:43.681215] E [MSGID: 114031]
> >>>>>>>>[client-rpc-fops.c:444:client3_3_open_cbk]
> >>>>>>>>0-home-lab-3-client-3: remote
> >>>>>>>>operation failed. Path: /cdc/kk.txt
> >>>>>>>>(cc98e831-3410-4202-8254-2d4b48e8ea68) [Permission denied]
> >>>>>>>>[2016-11-18 15:45:43.681297] W [fuse-bridge.c:989:fuse_fd_cbk]
> >>>>>>>>0-glusterfs-fuse: 399: OPEN() /cdc/kk.txt => -1 (Permission denied)
> >>>>>>>>[2016-11-18 15:45:55.457922] I [io-stats.c:1574:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3: --- fd stats ---
> >>>>>>>>[2016-11-18 15:45:55.457978] I [io-stats.c:1579:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3:       Filename : /cdc/444.txt
> >>>>>>>>[2016-11-18 15:45:55.457997] I [io-stats.c:1594:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3:   BytesWritten : 7 bytes
> >>>>>>>>[2016-11-18 15:45:55.458011] I [io-stats.c:1606:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3: Write 000004b+ : 1
> >>>>>>>>[2016-11-18 15:45:55.471933] I [io-stats.c:1574:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3: --- fd stats ---
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>* Logs on the glusterfs client side with DEBUG activated:
> >>>>>>>>
> >>>>>>>>[2016-11-18 16:06:17.040092] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>STAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:06:17.045986] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:06:17.046132] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2684:dht_lookup]
> >>>>>>>>0-home-lab-3-dht: Calling fresh lookup for /cdc/kk.txt on
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:06:17.046833] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2271:dht_lookup_cbk] 0-home-lab-3-dht: fresh_lookup
> >>>>>>>>returned for /cdc/kk.txt with op_ret 0 [Invalid argument]
> >>>>>>>>[2016-11-18 16:06:17.047671] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: UNLINK
> >>>>>>>>scheduled as normal fop
> >>>>>>>>[2016-11-18 16:06:17.050539] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph -1418558531
> >>>>>>>>[2016-11-18 16:06:17.050867] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:06:17.051948] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>[2016-11-18 16:06:17.051871] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:06:17.051946] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2684:dht_lookup]
> >>>>>>>>0-home-lab-3-dht: Calling fresh lookup for /cdc/444.txt on
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:06:17.062108] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2271:dht_lookup_cbk] 0-home-lab-3-dht: fresh_lookup
> >>>>>>>>returned for /cdc/444.txt with op_ret 0 [Invalid argument]
> >>>>>>>>[2016-11-18 16:06:17.063692] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph -1418558531
> >>>>>>>>[2016-11-18 16:06:17.064015] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:06:17.065068] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>The message "D [MSGID: 0] [io-threads.c:349:iot_schedule]
> >>>>>>>>0-home-lab-3-io-threads: STAT scheduled as fast fop" repeated 4 times
> >>>>>>>>between [2016-11-18 16:06:17.040092] and [2016-11-18 16:06:17.064175]
> >>>>>>>>[2016-11-18 16:06:17.065066] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:06:17.065232] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2684:dht_lookup]
> >>>>>>>>0-home-lab-3-dht: Calling fresh lookup for /cdc/444.txt on
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:06:17.065755] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.065897] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2271:dht_lookup_cbk] 0-home-lab-3-dht: fresh_lookup
> >>>>>>>>returned for /cdc/444.txt with op_ret -1 [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.066016] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2284:dht_lookup_cbk] 0-home-lab-3-dht: Entry
> >>>>>>>>/cdc/444.txt
> >>>>>>>>missing on subvol home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:06:17.066104] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2055:dht_lookup_everywhere] 0-home-lab-3-dht: winding
> >>>>>>>>lookup call to 4 subvols
> >>>>>>>>[2016-11-18 16:06:17.066594] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.066669] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:06:17.066771] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-client-1 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.066898] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-1
> >>>>>>>>[2016-11-18 16:06:17.066906] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-client-2 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.067019] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-2
> >>>>>>>>[2016-11-18 16:06:17.066915] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.067066] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:06:17.067107] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1527:dht_lookup_everywhere_done]
> >>>>>>>>0-home-lab-3-dht: STATUS:
> >>>>>>>>hashed_subvol home-lab-3-client-0 cached_subvol null
> >>>>>>>>[2016-11-18 16:06:17.067151] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1588:dht_lookup_everywhere_done] 0-home-lab-3-dht: There
> >>>>>>>>was no cached file and  unlink on hashed is not skipped /cdc/444.txt
> >>>>>>>>[2016-11-18 16:06:17.067179] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1591:dht_lookup_everywhere_done] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-dht returned -1
> >>>>>>>>error: No such
> >>>>>>>>file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.067206] D [MSGID: 0]
> >>>>>>>>[io-cache.c:256:ioc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e0498, home-lab-3-io-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.067250] D [MSGID: 0]
> >>>>>>>>[quick-read.c:447:qr_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e0498, home-lab-3-quick-read returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.067275] D [MSGID: 0]
> >>>>>>>>[md-cache.c:863:mdc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e0498, home-lab-3-md-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.067308] D [MSGID: 0]
> >>>>>>>>[defaults.c:1266:default_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e0498, home-lab-3-io-threads returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.067387] D [MSGID: 0]
> >>>>>>>>[io-stats.c:2116:io_stats_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e0498, home-lab-3 returned -1 error: No such file
> >>>>>>>>or directory
> >>>>>>>>[No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.068157] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:06:17.068281] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2684:dht_lookup]
> >>>>>>>>0-home-lab-3-dht: Calling fresh lookup for /cdc/444.txt on
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:06:17.068738] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.068781] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2271:dht_lookup_cbk] 0-home-lab-3-dht: fresh_lookup
> >>>>>>>>returned for /cdc/444.txt with op_ret -1 [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.068805] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2284:dht_lookup_cbk] 0-home-lab-3-dht: Entry
> >>>>>>>>/cdc/444.txt
> >>>>>>>>missing on subvol home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:06:17.068827] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2055:dht_lookup_everywhere] 0-home-lab-3-dht: winding
> >>>>>>>>lookup call to 4 subvols
> >>>>>>>>[2016-11-18 16:06:17.069286] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.069345] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:06:17.069452] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-client-2 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.069507] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-2
> >>>>>>>>[2016-11-18 16:06:17.069556] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.069585] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:06:17.069939] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-client-1 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.069983] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-1
> >>>>>>>>[2016-11-18 16:06:17.070005] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1527:dht_lookup_everywhere_done]
> >>>>>>>>0-home-lab-3-dht: STATUS:
> >>>>>>>>hashed_subvol home-lab-3-client-0 cached_subvol null
> >>>>>>>>[2016-11-18 16:06:17.070038] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1588:dht_lookup_everywhere_done] 0-home-lab-3-dht: There
> >>>>>>>>was no cached file and  unlink on hashed is not skipped /cdc/444.txt
> >>>>>>>>[2016-11-18 16:06:17.070098] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1591:dht_lookup_everywhere_done] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e0498, home-lab-3-dht returned -1
> >>>>>>>>error: No such
> >>>>>>>>file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.070128] D [MSGID: 0]
> >>>>>>>>[io-cache.c:256:ioc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e0498, home-lab-3-io-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.070154] D [MSGID: 0]
> >>>>>>>>[quick-read.c:447:qr_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e0498, home-lab-3-quick-read returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.070178] D [MSGID: 0]
> >>>>>>>>[md-cache.c:863:mdc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e0498, home-lab-3-md-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.070208] D [MSGID: 0]
> >>>>>>>>[defaults.c:1266:default_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e0498, home-lab-3-io-threads returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.070251] D [MSGID: 0]
> >>>>>>>>[io-stats.c:2116:io_stats_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e0498, home-lab-3 returned -1 error: No such file
> >>>>>>>>or directory
> >>>>>>>>[No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.070537] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>MKNOD scheduled
> >>>>>>>>as normal fop
> >>>>>>>>[2016-11-18 16:06:17.070826] D [MSGID: 0]
> >>>>>>>>[dht-common.c:5559:dht_mknod_wind_to_avail_subvol] 0-home-lab-3-dht:
> >>>>>>>>creating /cdc/444.txt on home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:06:17.071100] D [MSGID: 0]
> >>>>>>>>[dht-diskusage.c:92:dht_du_info_cbk] 0-home-lab-3-dht: subvolume
> >>>>>>>>'home-lab-3-client-1': avail_percent is: 96.00 and avail_space is:
> >>>>>>>>10456189239296 and avail_inodes is: 99.00
> >>>>>>>>[2016-11-18 16:06:17.071142] D [MSGID: 0]
> >>>>>>>>[dht-diskusage.c:92:dht_du_info_cbk] 0-home-lab-3-dht: subvolume
> >>>>>>>>'home-lab-3-client-0': avail_percent is: 95.00 and avail_space is:
> >>>>>>>>10499693871104 and avail_inodes is: 99.00
> >>>>>>>>[2016-11-18 16:06:17.071183] D [MSGID: 0]
> >>>>>>>>[dht-diskusage.c:92:dht_du_info_cbk] 0-home-lab-3-dht: subvolume
> >>>>>>>>'home-lab-3-client-2': avail_percent is: 96.00 and avail_space is:
> >>>>>>>>10500911267840 and avail_inodes is: 99.00
> >>>>>>>>[2016-11-18 16:06:17.071343] D [MSGID: 0]
> >>>>>>>>[dht-diskusage.c:92:dht_du_info_cbk] 0-home-lab-3-dht: subvolume
> >>>>>>>>'home-lab-3-client-3': avail_percent is: 95.00 and avail_space is:
> >>>>>>>>8600432410624 and avail_inodes is: 99.00
> >>>>>>>>[2016-11-18 16:06:17.073943] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph -1418558531
> >>>>>>>>[2016-11-18 16:06:17.074273] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>STAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:06:17.075035] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>OPEN scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:06:17.075913] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>WRITE scheduled
> >>>>>>>>as slow fop
> >>>>>>>>[2016-11-18 16:06:17.076205] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>FSTAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:06:17.076636] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:06:17.077282] D [fuse-bridge.c:52:fuse_invalidate]
> >>>>>>>>0-fuse: Invalidate inode id 140363155120276.
> >>>>>>>>[2016-11-18 16:06:17.077981] I [io-stats.c:1574:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3: --- fd stats ---
> >>>>>>>>[2016-11-18 16:06:17.078032] I [io-stats.c:1579:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3:       Filename : /cdc/444.txt
> >>>>>>>>[2016-11-18 16:06:17.078049] I [io-stats.c:1594:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3:   BytesWritten : 7 bytes
> >>>>>>>>[2016-11-18 16:06:17.078064] I [io-stats.c:1606:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3: Write 000004b+ : 1
> >>>>>>>>[2016-11-18 16:06:17.079156] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: SETATTR
> >>>>>>>>scheduled as normal fop
> >>>>>>>>[2016-11-18 16:06:17.079794] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:06:17.082196] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:06:17.082772] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>[2016-11-18 16:06:17.082318] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2684:dht_lookup]
> >>>>>>>>0-home-lab-3-dht: Calling fresh lookup for /cdc/kk.txt on
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:06:17.082770] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.083168] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2271:dht_lookup_cbk] 0-home-lab-3-dht: fresh_lookup
> >>>>>>>>returned for /cdc/kk.txt with op_ret -1 [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.083282] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2284:dht_lookup_cbk] 0-home-lab-3-dht: Entry /cdc/kk.txt
> >>>>>>>>missing on subvol home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:06:17.083320] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2055:dht_lookup_everywhere] 0-home-lab-3-dht: winding
> >>>>>>>>lookup call to 4 subvols
> >>>>>>>>[2016-11-18 16:06:17.083991] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.084043] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:06:17.084048] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.084092] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:06:17.084114] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-1 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.084167] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-1
> >>>>>>>>[2016-11-18 16:06:17.084091] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-2 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.084377] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-2
> >>>>>>>>[2016-11-18 16:06:17.084406] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1527:dht_lookup_everywhere_done]
> >>>>>>>>0-home-lab-3-dht: STATUS:
> >>>>>>>>hashed_subvol home-lab-3-client-3 cached_subvol null
> >>>>>>>>[2016-11-18 16:06:17.084511] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1588:dht_lookup_everywhere_done] 0-home-lab-3-dht: There
> >>>>>>>>was no cached file and  unlink on hashed is not skipped /cdc/kk.txt
> >>>>>>>>[2016-11-18 16:06:17.084534] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1591:dht_lookup_everywhere_done] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-dht returned -1
> >>>>>>>>error: No such
> >>>>>>>>file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.084683] D [MSGID: 0]
> >>>>>>>>[io-cache.c:256:ioc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.084783] D [MSGID: 0]
> >>>>>>>>[quick-read.c:447:qr_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-quick-read returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.084857] D [MSGID: 0]
> >>>>>>>>[md-cache.c:863:mdc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-md-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.084889] D [MSGID: 0]
> >>>>>>>>[defaults.c:1266:default_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-threads returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.085001] D [MSGID: 0]
> >>>>>>>>[io-stats.c:2116:io_stats_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3 returned -1 error: No such file
> >>>>>>>>or directory
> >>>>>>>>[No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.086098] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>STAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:06:17.087256] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>[2016-11-18 16:06:17.087173] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:06:17.087254] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2684:dht_lookup]
> >>>>>>>>0-home-lab-3-dht: Calling fresh lookup for /cdc/kk.txt on
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:06:17.087749] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.087795] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2271:dht_lookup_cbk] 0-home-lab-3-dht: fresh_lookup
> >>>>>>>>returned for /cdc/kk.txt with op_ret -1 [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.088014] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2284:dht_lookup_cbk] 0-home-lab-3-dht: Entry /cdc/kk.txt
> >>>>>>>>missing on subvol home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:06:17.088036] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2055:dht_lookup_everywhere] 0-home-lab-3-dht: winding
> >>>>>>>>lookup call to 4 subvols
> >>>>>>>>[2016-11-18 16:06:17.088598] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.088639] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:06:17.088804] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-2 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.088855] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-2
> >>>>>>>>[2016-11-18 16:06:17.088819] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.089069] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:06:17.089380] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-1 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.089421] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-1
> >>>>>>>>[2016-11-18 16:06:17.089443] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1527:dht_lookup_everywhere_done]
> >>>>>>>>0-home-lab-3-dht: STATUS:
> >>>>>>>>hashed_subvol home-lab-3-client-3 cached_subvol null
> >>>>>>>>[2016-11-18 16:06:17.089463] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1588:dht_lookup_everywhere_done] 0-home-lab-3-dht: There
> >>>>>>>>was no cached file and  unlink on hashed is not skipped /cdc/kk.txt
> >>>>>>>>[2016-11-18 16:06:17.089575] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1591:dht_lookup_everywhere_done] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-dht returned -1
> >>>>>>>>error: No such
> >>>>>>>>file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.089601] D [MSGID: 0]
> >>>>>>>>[io-cache.c:256:ioc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.089712] D [MSGID: 0]
> >>>>>>>>[quick-read.c:447:qr_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-quick-read returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.089738] D [MSGID: 0]
> >>>>>>>>[md-cache.c:863:mdc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-md-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.090006] D [MSGID: 0]
> >>>>>>>>[defaults.c:1266:default_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-threads returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.090156] D [MSGID: 0]
> >>>>>>>>[io-stats.c:2116:io_stats_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3 returned -1 error: No such file
> >>>>>>>>or directory
> >>>>>>>>[No such file or directory]
> >>>>>>>>[2016-11-18 16:06:17.090648] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>MKNOD scheduled
> >>>>>>>>as normal fop
> >>>>>>>>[2016-11-18 16:06:17.090732] D [MSGID: 0]
> >>>>>>>>[dht-common.c:5559:dht_mknod_wind_to_avail_subvol] 0-home-lab-3-dht:
> >>>>>>>>creating /cdc/kk.txt on home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:06:17.091499] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph -1418558531
> >>>>>>>>[2016-11-18 16:06:17.091843] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: SETATTR
> >>>>>>>>scheduled as normal fop
> >>>>>>>>[2016-11-18 16:06:17.093831] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:06:17.094711] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>[2016-11-18 16:06:17.093216] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: SETATTR
> >>>>>>>>scheduled as normal fop
> >>>>>>>>[2016-11-18 16:06:17.094709] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>OPEN scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:06:17.095280] E [MSGID: 114031]
> >>>>>>>>[client-rpc-fops.c:444:client3_3_open_cbk]
> >>>>>>>>0-home-lab-3-client-3: remote
> >>>>>>>>operation failed. Path: /cdc/kk.txt
> >>>>>>>>(09bfb6fa-82fb-463b-abd9-bb7ef88e10c0) [Permission denied]
> >>>>>>>>[2016-11-18 16:06:17.095341] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:448:client3_3_open_cbk] 0-stack-trace:
> >>>>>>>>stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-client-3 returned -1 error:
> >>>>>>>>Permission denied
> >>>>>>>>[Permission denied]
> >>>>>>>>[2016-11-18 16:06:17.095366] D [MSGID: 0]
> >>>>>>>>[dht-inode-read.c:45:dht_open_cbk] 0-home-lab-3-dht: subvolume
> >>>>>>>>home-lab-3-client-3 returned -1 [Permission denied]
> >>>>>>>>[2016-11-18 16:06:17.095480] D [MSGID: 0]
> >>>>>>>>[dht-inode-read.c:59:dht_open_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-dht returned -1 error: Permission denied
> >>>>>>>>[Permission denied]
> >>>>>>>>[2016-11-18 16:06:17.095671] D [MSGID: 0]
> >>>>>>>>[read-ahead.c:101:ra_open_cbk]
> >>>>>>>>0-stack-trace: stack-address: 0x7fa8ee0e1310, home-lab-3-read-ahead
> >>>>>>>>returned -1 error: Permission denied [Permission denied]
> >>>>>>>>[2016-11-18 16:06:17.095759] D [MSGID: 0]
> >>>>>>>>[io-cache.c:605:ioc_open_cbk]
> >>>>>>>>0-stack-trace: stack-address: 0x7fa8ee0e1310, home-lab-3-io-cache
> >>>>>>>>returned -1 error: Permission denied [Permission denied]
> >>>>>>>>[2016-11-18 16:06:17.095963] D [MSGID: 0]
> >>>>>>>>[defaults.c:1137:default_open_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-quick-read returned -1 error: Permission
> >>>>>>>>denied [Permission denied]
> >>>>>>>>[2016-11-18 16:06:17.095988] D [MSGID: 0]
> >>>>>>>>[defaults.c:1137:default_open_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-threads returned -1 error: Permission
> >>>>>>>>denied [Permission denied]
> >>>>>>>>[2016-11-18 16:06:17.096275] D [MSGID: 0]
> >>>>>>>>[io-stats.c:1936:io_stats_open_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3 returned -1 error: Permission denied
> >>>>>>>>[Permission denied]
> >>>>>>>>[2016-11-18 16:06:17.096362] W [fuse-bridge.c:989:fuse_fd_cbk]
> >>>>>>>>0-glusterfs-fuse: 338: OPEN() /cdc/kk.txt => -1 (Permission denied)
> >>>>>>>>[2016-11-18 16:06:17.097104] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: SETATTR
> >>>>>>>>scheduled as normal fop
> >>>>>>>>[2016-11-18 16:06:17.097674] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:06:17.099912] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:06:24.785225] D
> >>>>>>>>[rpc-clnt-ping.c:295:rpc_clnt_start_ping]
> >>>>>>>>0-home-lab-3-client-0: returning as transport is already
> >>>>>>>>disconnected OR
> >>>>>>>>there are no frames (0 || 0)
> >>>>>>>>[2016-11-18 16:06:24.785338] D
> >>>>>>>>[rpc-clnt-ping.c:295:rpc_clnt_start_ping]
> >>>>>>>>0-home-lab-3-client-1: returning as transport is already
> >>>>>>>>disconnected OR
> >>>>>>>>there are no frames (0 || 0)
> >>>>>>>>[2016-11-18 16:06:24.785359] D
> >>>>>>>>[rpc-clnt-ping.c:295:rpc_clnt_start_ping]
> >>>>>>>>0-home-lab-3-client-2: returning as transport is already
> >>>>>>>>disconnected OR
> >>>>>>>>there are no frames (0 || 0)
> >>>>>>>>[2016-11-18 16:06:24.785377] D
> >>>>>>>>[rpc-clnt-ping.c:295:rpc_clnt_start_ping]
> >>>>>>>>0-home-lab-3-client-3: returning as transport is already
> >>>>>>>>disconnected OR
> >>>>>>>>there are no frames (0 || 0)
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>** TEST DONE as user cdc --> ERROR
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>[2016-11-18 16:06:46.737686] D
> >>>>>>>>[rpc-clnt-ping.c:93:rpc_clnt_remove_ping_timer_locked] (-->
> >>>>>>>>/lib64/libglusterfs.so.0(_gf_log_callingfn+0x1a3)[0x7fa8f0851da3] (-->
> >>>>>>>>/lib64/libgfrpc.so.0(rpc_clnt_remove_ping_timer_locked+0x84)[0x7fa8f061f184]
> >>>>>>>>
> >>>>>>>>(--> /lib64/libgfrpc.so.0(+0x13787)[0x7fa8f061f787] (-->
> >>>>>>>>/lib64/libgfrpc.so.0(rpc_clnt_submit+0x29a)[0x7fa8f061c07a] (-->
> >>>>>>>>/usr/lib64/glusterfs/3.8.5/xlator/protocol/client.so(+0xefce)[0x7fa8e22fffce]
> >>>>>>>>
> >>>>>>>>))))) 0-: 138.4.2.246:49172: ping timer event already removed
> >>>>>>>>[2016-11-18 16:06:49.545698] D
> >>>>>>>>[rpc-clnt-ping.c:93:rpc_clnt_remove_ping_timer_locked] (-->
> >>>>>>>>/lib64/libglusterfs.so.0(_gf_log_callingfn+0x1a3)[0x7fa8f0851da3] (-->
> >>>>>>>>/lib64/libgfrpc.so.0(rpc_clnt_remove_ping_timer_locked+0x84)[0x7fa8f061f184]
> >>>>>>>>
> >>>>>>>>(--> /lib64/libgfrpc.so.0(+0x13787)[0x7fa8f061f787] (-->
> >>>>>>>>/lib64/libgfrpc.so.0(rpc_clnt_submit+0x29a)[0x7fa8f061c07a] (-->
> >>>>>>>>/usr/lib64/glusterfs/3.8.5/xlator/protocol/client.so(+0xefce)[0x7fa8e22fffce]
> >>>>>>>>
> >>>>>>>>))))) 0-: 138.4.2.177:49157: ping timer event already removed
> >>>>>>>>[2016-11-18 16:06:49.546474] D
> >>>>>>>>[rpc-clnt-ping.c:93:rpc_clnt_remove_ping_timer_locked] (-->
> >>>>>>>>/lib64/libglusterfs.so.0(_gf_log_callingfn+0x1a3)[0x7fa8f0851da3] (-->
> >>>>>>>>/lib64/libgfrpc.so.0(rpc_clnt_remove_ping_timer_locked+0x84)[0x7fa8f061f184]
> >>>>>>>>
> >>>>>>>>(--> /lib64/libgfrpc.so.0(+0x13787)[0x7fa8f061f787] (-->
> >>>>>>>>/lib64/libgfrpc.so.0(rpc_clnt_submit+0x29a)[0x7fa8f061c07a] (-->
> >>>>>>>>/usr/lib64/glusterfs/3.8.5/xlator/protocol/client.so(+0xefce)[0x7fa8e22fffce]
> >>>>>>>>
> >>>>>>>>))))) 0-: 138.4.2.189:49157: ping timer event already removed
> >>>>>>>>[2016-11-18 16:06:49.547093] D
> >>>>>>>>[rpc-clnt-ping.c:93:rpc_clnt_remove_ping_timer_locked] (-->
> >>>>>>>>/lib64/libglusterfs.so.0(_gf_log_callingfn+0x1a3)[0x7fa8f0851da3] (-->
> >>>>>>>>/lib64/libgfrpc.so.0(rpc_clnt_remove_ping_timer_locked+0x84)[0x7fa8f061f184]
> >>>>>>>>
> >>>>>>>>(--> /lib64/libgfrpc.so.0(+0x13787)[0x7fa8f061f787] (-->
> >>>>>>>>/lib64/libgfrpc.so.0(rpc_clnt_submit+0x29a)[0x7fa8f061c07a] (-->
> >>>>>>>>/usr/lib64/glusterfs/3.8.5/xlator/protocol/client.so(+0xefce)[0x7fa8e22fffce]
> >>>>>>>>
> >>>>>>>>))))) 0-: 138.4.2.248:49157: ping timer event already removed
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>** user CDC becomed root at this point
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>[2016-11-18 16:07:11.907892] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>The message "D [MSGID: 0] [io-threads.c:349:iot_schedule]
> >>>>>>>>0-home-lab-3-io-threads: STAT scheduled as fast fop" repeated 7 times
> >>>>>>>>between [2016-11-18 16:06:17.086098] and [2016-11-18 16:07:11.906944]
> >>>>>>>>[2016-11-18 16:07:11.907884] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:07:11.908875] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph -1418558531
> >>>>>>>>[2016-11-18 16:07:11.909179] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:07:11.909256] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>The message "D [MSGID: 0] [io-threads.c:349:iot_schedule]
> >>>>>>>>0-home-lab-3-io-threads: UNLINK scheduled as normal fop" repeated 2
> >>>>>>>>times between [2016-11-18 16:06:17.047671] and [2016-11-18
> >>>>>>>>16:07:11.908114]
> >>>>>>>>[2016-11-18 16:07:11.909254] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>STAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:07:11.911109] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>[2016-11-18 16:07:11.911018] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:07:11.911107] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: UNLINK
> >>>>>>>>scheduled as normal fop
> >>>>>>>>[2016-11-18 16:07:11.911871] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph -1418558531
> >>>>>>>>[2016-11-18 16:07:11.912045] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:07:11.913067] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>The message "D [MSGID: 0] [io-threads.c:349:iot_schedule]
> >>>>>>>>0-home-lab-3-io-threads: STAT scheduled as fast fop" repeated 2 times
> >>>>>>>>between [2016-11-18 16:07:11.909254] and [2016-11-18 16:07:11.912165]
> >>>>>>>>[2016-11-18 16:07:11.913065] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:07:11.913193] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2684:dht_lookup]
> >>>>>>>>0-home-lab-3-dht: Calling fresh lookup for /cdc/444.txt on
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:07:11.913710] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.913757] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2271:dht_lookup_cbk] 0-home-lab-3-dht: fresh_lookup
> >>>>>>>>returned for /cdc/444.txt with op_ret -1 [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.913788] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2284:dht_lookup_cbk] 0-home-lab-3-dht: Entry
> >>>>>>>>/cdc/444.txt
> >>>>>>>>missing on subvol home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:07:11.913810] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2055:dht_lookup_everywhere] 0-home-lab-3-dht: winding
> >>>>>>>>lookup call to 4 subvols
> >>>>>>>>[2016-11-18 16:07:11.914336] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.914379] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:07:11.914424] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-1 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.914448] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-1
> >>>>>>>>[2016-11-18 16:07:11.914501] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.914617] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:07:11.914649] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-2 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.914698] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-2
> >>>>>>>>[2016-11-18 16:07:11.914724] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1527:dht_lookup_everywhere_done]
> >>>>>>>>0-home-lab-3-dht: STATUS:
> >>>>>>>>hashed_subvol home-lab-3-client-0 cached_subvol null
> >>>>>>>>[2016-11-18 16:07:11.914743] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1588:dht_lookup_everywhere_done] 0-home-lab-3-dht: There
> >>>>>>>>was no cached file and  unlink on hashed is not skipped /cdc/444.txt
> >>>>>>>>[2016-11-18 16:07:11.914764] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1591:dht_lookup_everywhere_done] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-dht returned -1
> >>>>>>>>error: No such
> >>>>>>>>file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.914791] D [MSGID: 0]
> >>>>>>>>[io-cache.c:256:ioc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.914825] D [MSGID: 0]
> >>>>>>>>[quick-read.c:447:qr_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-quick-read returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.914855] D [MSGID: 0]
> >>>>>>>>[md-cache.c:863:mdc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-md-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.914880] D [MSGID: 0]
> >>>>>>>>[defaults.c:1266:default_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-threads returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.914947] D [MSGID: 0]
> >>>>>>>>[io-stats.c:2116:io_stats_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3 returned -1 error: No such file
> >>>>>>>>or directory
> >>>>>>>>[No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.915569] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:07:11.915644] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2684:dht_lookup]
> >>>>>>>>0-home-lab-3-dht: Calling fresh lookup for /cdc/444.txt on
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:07:11.916090] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.916134] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2271:dht_lookup_cbk] 0-home-lab-3-dht: fresh_lookup
> >>>>>>>>returned for /cdc/444.txt with op_ret -1 [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.916158] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2284:dht_lookup_cbk] 0-home-lab-3-dht: Entry
> >>>>>>>>/cdc/444.txt
> >>>>>>>>missing on subvol home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:07:11.916185] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2055:dht_lookup_everywhere] 0-home-lab-3-dht: winding
> >>>>>>>>lookup call to 4 subvols
> >>>>>>>>[2016-11-18 16:07:11.916593] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.916780] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:07:11.916878] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.916994] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:07:11.917076] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-2 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.916906] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-1 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.917117] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-2
> >>>>>>>>[2016-11-18 16:07:11.917153] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/444.txt) from subvol
> >>>>>>>>home-lab-3-client-1
> >>>>>>>>[2016-11-18 16:07:11.917205] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1527:dht_lookup_everywhere_done]
> >>>>>>>>0-home-lab-3-dht: STATUS:
> >>>>>>>>hashed_subvol home-lab-3-client-0 cached_subvol null
> >>>>>>>>[2016-11-18 16:07:11.917368] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1588:dht_lookup_everywhere_done] 0-home-lab-3-dht: There
> >>>>>>>>was no cached file and  unlink on hashed is not skipped /cdc/444.txt
> >>>>>>>>[2016-11-18 16:07:11.917437] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1591:dht_lookup_everywhere_done] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-dht returned -1
> >>>>>>>>error: No such
> >>>>>>>>file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.917467] D [MSGID: 0]
> >>>>>>>>[io-cache.c:256:ioc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.917496] D [MSGID: 0]
> >>>>>>>>[quick-read.c:447:qr_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-quick-read returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.917521] D [MSGID: 0]
> >>>>>>>>[md-cache.c:863:mdc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-md-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.917551] D [MSGID: 0]
> >>>>>>>>[defaults.c:1266:default_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-threads returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.917726] D [MSGID: 0]
> >>>>>>>>[io-stats.c:2116:io_stats_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3 returned -1 error: No such file
> >>>>>>>>or directory
> >>>>>>>>[No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.917958] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>MKNOD scheduled
> >>>>>>>>as normal fop
> >>>>>>>>[2016-11-18 16:07:11.918230] D [MSGID: 0]
> >>>>>>>>[dht-common.c:5559:dht_mknod_wind_to_avail_subvol] 0-home-lab-3-dht:
> >>>>>>>>creating /cdc/444.txt on home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:07:11.918488] D [MSGID: 0]
> >>>>>>>>[dht-diskusage.c:92:dht_du_info_cbk] 0-home-lab-3-dht: subvolume
> >>>>>>>>'home-lab-3-client-1': avail_percent is: 96.00 and avail_space is:
> >>>>>>>>10456166432768 and avail_inodes is: 99.00
> >>>>>>>>[2016-11-18 16:07:11.918570] D [MSGID: 0]
> >>>>>>>>[dht-diskusage.c:92:dht_du_info_cbk] 0-home-lab-3-dht: subvolume
> >>>>>>>>'home-lab-3-client-3': avail_percent is: 95.00 and avail_space is:
> >>>>>>>>8600417075200 and avail_inodes is: 99.00
> >>>>>>>>[2016-11-18 16:07:11.918603] D [MSGID: 0]
> >>>>>>>>[dht-diskusage.c:92:dht_du_info_cbk] 0-home-lab-3-dht: subvolume
> >>>>>>>>'home-lab-3-client-2': avail_percent is: 96.00 and avail_space is:
> >>>>>>>>10500905500672 and avail_inodes is: 99.00
> >>>>>>>>[2016-11-18 16:07:11.918675] D [MSGID: 0]
> >>>>>>>>[dht-diskusage.c:92:dht_du_info_cbk] 0-home-lab-3-dht: subvolume
> >>>>>>>>'home-lab-3-client-0': avail_percent is: 95.00 and avail_space is:
> >>>>>>>>10499686531072 and avail_inodes is: 99.00
> >>>>>>>>[2016-11-18 16:07:11.919095] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph -1418558531
> >>>>>>>>[2016-11-18 16:07:11.919377] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>STAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:07:11.920040] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>OPEN scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:07:11.920889] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>WRITE scheduled
> >>>>>>>>as slow fop
> >>>>>>>>[2016-11-18 16:07:11.921051] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>FSTAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:07:11.921583] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:07:11.922068] D [fuse-bridge.c:52:fuse_invalidate]
> >>>>>>>>0-fuse: Invalidate inode id 140363155120276.
> >>>>>>>>[2016-11-18 16:07:11.922936] I [io-stats.c:1574:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3: --- fd stats ---
> >>>>>>>>[2016-11-18 16:07:11.922988] I [io-stats.c:1579:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3:       Filename : /cdc/444.txt
> >>>>>>>>[2016-11-18 16:07:11.923004] I [io-stats.c:1594:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3:   BytesWritten : 7 bytes
> >>>>>>>>[2016-11-18 16:07:11.923026] I [io-stats.c:1606:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3: Write 000004b+ : 1
> >>>>>>>>[2016-11-18 16:07:11.923779] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>STAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:07:11.924504] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:07:11.926692] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>The message "D [MSGID: 0] [io-threads.c:349:iot_schedule]
> >>>>>>>>0-home-lab-3-io-threads: SETATTR scheduled as normal fop" repeated 2
> >>>>>>>>times between [2016-11-18 16:06:17.097104] and [2016-11-18
> >>>>>>>>16:07:11.923946]
> >>>>>>>>[2016-11-18 16:07:11.926690] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:07:11.926858] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2684:dht_lookup]
> >>>>>>>>0-home-lab-3-dht: Calling fresh lookup for /cdc/kk.txt on
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:07:11.927327] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.927376] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2271:dht_lookup_cbk] 0-home-lab-3-dht: fresh_lookup
> >>>>>>>>returned for /cdc/kk.txt with op_ret -1 [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.927401] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2284:dht_lookup_cbk] 0-home-lab-3-dht: Entry /cdc/kk.txt
> >>>>>>>>missing on subvol home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:07:11.927422] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2055:dht_lookup_everywhere] 0-home-lab-3-dht: winding
> >>>>>>>>lookup call to 4 subvols
> >>>>>>>>[2016-11-18 16:07:11.927940] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.927987] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:07:11.928043] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-2 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.928055] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.928058] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-1 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.928170] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-1
> >>>>>>>>[2016-11-18 16:07:11.928174] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:07:11.928277] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-2
> >>>>>>>>[2016-11-18 16:07:11.928360] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1527:dht_lookup_everywhere_done]
> >>>>>>>>0-home-lab-3-dht: STATUS:
> >>>>>>>>hashed_subvol home-lab-3-client-3 cached_subvol null
> >>>>>>>>[2016-11-18 16:07:11.928381] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1588:dht_lookup_everywhere_done] 0-home-lab-3-dht: There
> >>>>>>>>was no cached file and  unlink on hashed is not skipped /cdc/kk.txt
> >>>>>>>>[2016-11-18 16:07:11.928403] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1591:dht_lookup_everywhere_done] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-dht returned -1
> >>>>>>>>error: No such
> >>>>>>>>file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.928431] D [MSGID: 0]
> >>>>>>>>[io-cache.c:256:ioc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.928456] D [MSGID: 0]
> >>>>>>>>[quick-read.c:447:qr_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-quick-read returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.928480] D [MSGID: 0]
> >>>>>>>>[md-cache.c:863:mdc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-md-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.928511] D [MSGID: 0]
> >>>>>>>>[defaults.c:1266:default_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-threads returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.928753] D [MSGID: 0]
> >>>>>>>>[io-stats.c:2116:io_stats_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3 returned -1 error: No such file
> >>>>>>>>or directory
> >>>>>>>>[No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.930485] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>[2016-11-18 16:07:11.929862] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>STAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:07:11.930483] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: LOOKUP
> >>>>>>>>scheduled as fast fop
> >>>>>>>>[2016-11-18 16:07:11.930602] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2684:dht_lookup]
> >>>>>>>>0-home-lab-3-dht: Calling fresh lookup for /cdc/kk.txt on
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:07:11.931071] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.931124] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2271:dht_lookup_cbk] 0-home-lab-3-dht: fresh_lookup
> >>>>>>>>returned for /cdc/kk.txt with op_ret -1 [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.931148] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2284:dht_lookup_cbk] 0-home-lab-3-dht: Entry /cdc/kk.txt
> >>>>>>>>missing on subvol home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:07:11.931348] D [MSGID: 0]
> >>>>>>>>[dht-common.c:2055:dht_lookup_everywhere] 0-home-lab-3-dht: winding
> >>>>>>>>lookup call to 4 subvols
> >>>>>>>>[2016-11-18 16:07:11.931880] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-0 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.931927] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-0
> >>>>>>>>[2016-11-18 16:07:11.932002] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-3 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.931994] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-2 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.931991] D [MSGID: 0]
> >>>>>>>>[client-rpc-fops.c:2945:client3_3_lookup_cbk] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-client-1 returned
> >>>>>>>>-1 error: No
> >>>>>>>>such file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.932078] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-2
> >>>>>>>>[2016-11-18 16:07:11.932116] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-1
> >>>>>>>>[2016-11-18 16:07:11.932315] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1862:dht_lookup_everywhere_cbk]
> >>>>>>>>0-home-lab-3-dht: returned
> >>>>>>>>with op_ret -1 and op_errno 2 (/cdc/kk.txt) from subvol
> >>>>>>>>home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:07:11.932363] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1527:dht_lookup_everywhere_done]
> >>>>>>>>0-home-lab-3-dht: STATUS:
> >>>>>>>>hashed_subvol home-lab-3-client-3 cached_subvol null
> >>>>>>>>[2016-11-18 16:07:11.932383] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1588:dht_lookup_everywhere_done] 0-home-lab-3-dht: There
> >>>>>>>>was no cached file and  unlink on hashed is not skipped /cdc/kk.txt
> >>>>>>>>[2016-11-18 16:07:11.932407] D [MSGID: 0]
> >>>>>>>>[dht-common.c:1591:dht_lookup_everywhere_done] 0-stack-trace:
> >>>>>>>>stack-address: 0x7fa8ee0e1310, home-lab-3-dht returned -1
> >>>>>>>>error: No such
> >>>>>>>>file or directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.932446] D [MSGID: 0]
> >>>>>>>>[io-cache.c:256:ioc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.932471] D [MSGID: 0]
> >>>>>>>>[quick-read.c:447:qr_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-quick-read returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.932494] D [MSGID: 0]
> >>>>>>>>[md-cache.c:863:mdc_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-md-cache returned -1 error: No such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.932518] D [MSGID: 0]
> >>>>>>>>[defaults.c:1266:default_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3-io-threads returned -1 error: No
> >>>>>>>>such file or
> >>>>>>>>directory [No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.932725] D [logging.c:1953:_gf_msg_internal]
> >>>>>>>>0-logging-infra: Buffer overflow of a buffer whose size limit is 5.
> >>>>>>>>About to flush least recently used log message to disk
> >>>>>>>>[2016-11-18 16:07:11.932545] D [MSGID: 0]
> >>>>>>>>[io-stats.c:2116:io_stats_lookup_cbk] 0-stack-trace: stack-address:
> >>>>>>>>0x7fa8ee0e1310, home-lab-3 returned -1 error: No such file
> >>>>>>>>or directory
> >>>>>>>>[No such file or directory]
> >>>>>>>>[2016-11-18 16:07:11.932722] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>MKNOD scheduled
> >>>>>>>>as normal fop
> >>>>>>>>[2016-11-18 16:07:11.933008] D [MSGID: 0]
> >>>>>>>>[dht-common.c:5559:dht_mknod_wind_to_avail_subvol] 0-home-lab-3-dht:
> >>>>>>>>creating /cdc/kk.txt on home-lab-3-client-3
> >>>>>>>>[2016-11-18 16:07:11.934086] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph -1418558531
> >>>>>>>>[2016-11-18 16:07:11.934323] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: SETATTR
> >>>>>>>>scheduled as normal fop
> >>>>>>>>[2016-11-18 16:07:11.934922] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>STAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:07:11.935497] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: SETATTR
> >>>>>>>>scheduled as normal fop
> >>>>>>>>[2016-11-18 16:07:11.936102] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:07:11.936903] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>OPEN scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:07:11.937540] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>WRITE scheduled
> >>>>>>>>as slow fop
> >>>>>>>>[2016-11-18 16:07:11.937682] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads:
> >>>>>>>>FSTAT scheduled
> >>>>>>>>as fast fop
> >>>>>>>>[2016-11-18 16:07:11.938267] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:07:11.938757] D [fuse-bridge.c:52:fuse_invalidate]
> >>>>>>>>0-fuse: Invalidate inode id 140363155120652.
> >>>>>>>>[2016-11-18 16:07:11.938994] I [io-stats.c:1574:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3: --- fd stats ---
> >>>>>>>>[2016-11-18 16:07:11.939072] I [io-stats.c:1579:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3:       Filename : /cdc/kk.txt
> >>>>>>>>[2016-11-18 16:07:11.939096] I [io-stats.c:1594:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3:   BytesWritten : 7 bytes
> >>>>>>>>[2016-11-18 16:07:11.939112] I [io-stats.c:1606:io_stats_dump_fd]
> >>>>>>>>0-home-lab-3: Write 000004b+ : 1
> >>>>>>>>[2016-11-18 16:07:11.939448] D [MSGID: 0]
> >>>>>>>>[io-threads.c:349:iot_schedule] 0-home-lab-3-io-threads: SETATTR
> >>>>>>>>scheduled as normal fop
> >>>>>>>>[2016-11-18 16:07:11.940028] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>[2016-11-18 16:07:11.942130] D [fuse-bridge.c:5264:notify] 0-fuse: got
> >>>>>>>>event 19 on graph 0
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>** TEST DONE as root --> NO PROBLEM
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>[2016-11-18 16:07:28.794150] D
> >>>>>>>>[rpc-clnt-ping.c:295:rpc_clnt_start_ping]
> >>>>>>>>0-home-lab-3-client-2: returning as transport is already
> >>>>>>>>disconnected OR
> >>>>>>>>there are no frames (0 || 0)
> >>>>>>>>[2016-11-18 16:07:31.794656] D
> >>>>>>>>[rpc-clnt-ping.c:295:rpc_clnt_start_ping]
> >>>>>>>>0-home-lab-3-client-0: returning as transport is already
> >>>>>>>>disconnected OR
> >>>>>>>>there are no frames (0 || 0)
> >>>>>>>>[2016-11-18 16:07:31.794925] D
> >>>>>>>>[rpc-clnt-ping.c:295:rpc_clnt_start_ping]
> >>>>>>>>0-home-lab-3-client-1: returning as transport is already
> >>>>>>>>disconnected OR
> >>>>>>>>there are no frames (0 || 0)
> >>>>>>>>[2016-11-18 16:07:31.794984] D
> >>>>>>>>[rpc-clnt-ping.c:295:rpc_clnt_start_ping]
> >>>>>>>>0-home-lab-3-client-3: returning as transport is already
> >>>>>>>>disconnected OR
> >>>>>>>>there are no frames (0 || 0)
> >>>>>>>>
> >>>>>>>>
> >>>>>>>>** USER ROOT EXITED at this point
> >>>>>>>>
> >>>>>>>>El 18/11/16 a las 15:16, Miklos Szeredi escribió:
> >>>>>>>>>On Wed, Nov 16, 2016 at 7:19 PM, Omar Walid Llorente
> >>>>>>>>><omar@dit.upm.es>
> >>>>>>>>>wrote:
> >>>>>>>>>
> >>>>>>>>>>In any case, the kernel we are using (3.13.0-96-generic #143-Ubuntu
> >>>>>>>>>>SMP Mon
> >>>>>>>>>>Aug 29 20:15:20 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux) has fuse
> >>>>>>>>>>included
> >>>>>>>>>>(not as a module) so if it would be necessary to change
> >>>>>>>>>>the fuse mount
> >>>>>>>>>>options some help would be needed.
> >>>>>>>>>Can you reproduce this on latest (e.g 4.8) kernel?
> >>>>>>>>>
> >>>>>>>>>Also fuse debug logs (with whaterver kernel) could be
> >>>>>>>>>useful; not sure
> >>>>>>>>>how to enable it for glusterfs, usual convention for fuse filesystems
> >>>>>>>>>is "-d".
> >>>>>>>>>
> >>>>>>>>>Thanks,
> >>>>>>>>>Miklos
> >>>>>>-- 
> >>>>>>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>>>>>the body of a message tomajordomo@vger.kernel.org
> >>>>>>More majordomo info athttp://vger.kernel.org/majordomo-info.html
> >>>>>>
> >>>>-- 
> >>>>----------------------------------------------------------------
> >>>>Centro de Cálculo         Depto. Ingeniería Sistemas Telemáticos
> >>>>E-mail:omar@dit.upm.es         Universidad Politécnica de Madrid
> >>>>Fax:(+34) 913367333                 E.T.S. Ing. Telecomunicación
> >>>>Tel:(+34) 915495700-Ext.3005                28040 Madrid (Spain)
> >>>>Tel:(+34) 915495762-Ext.3005
> >>>>Tel:(+34) 913367366-Ext.3005
> >>>>----------------------------------------------------------------
> >>-- 
> >>----------------------------------------------------------------
> >>Centro de Cálculo         Depto. Ingeniería Sistemas Telemáticos
> >>E-mail:omar@dit.upm.es         Universidad Politécnica de Madrid
> >>Fax:(+34) 913367333                 E.T.S. Ing. Telecomunicación
> >>Tel:(+34) 915495700-Ext.3005                28040 Madrid (Spain)
> >>Tel:(+34) 915495762-Ext.3005
> >>Tel:(+34) 913367366-Ext.3005
> >>----------------------------------------------------------------
> >>
> >>--
> >>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>the body of a message tomajordomo@vger.kernel.org
> >>More majordomo info athttp://vger.kernel.org/majordomo-info.html
> >>
> >>
> >>::DISCLAIMER::
> >>----------------------------------------------------------------------------------------------------------------------------------------------------
> >>
> >>The contents of this e-mail and any attachment(s) are confidential and intended for the named recipient(s) only.
> >>E-mail transmission is not guaranteed to be secure or error-free as information could be intercepted, corrupted,
> >>lost, destroyed, arrive late or incomplete, or may contain viruses in transmission. The e mail and its contents
> >>(with or without referred errors) shall therefore not attach any liability on the originator or HCL or its affiliates.
> >>Views or opinions, if any, presented in this email are solely those of the author and may not necessarily reflect the
> >>views or opinions of HCL or its affiliates. Any form of reproduction, dissemination, copying, disclosure, modification,
> >>distribution and / or publication of this message without the prior written consent of authorized representative of
> >>HCL is strictly prohibited. If you have received this email in error please delete it and notify the sender immediately.
> >>Before opening any email and/or attachments, please check them for viruses and other defects.
> >>
> >>----------------------------------------------------------------------------------------------------------------------------------------------------
> 
> -- 
> ----------------------------------------------------------------
> Centro de Cálculo         Depto. Ingeniería Sistemas Telemáticos
> E-mail:omar@dit.upm.es         Universidad Politécnica de Madrid
> Fax:(+34) 913367333                 E.T.S. Ing. Telecomunicación
> Tel:(+34) 915495700-Ext.3005                28040 Madrid (Spain)
> Tel:(+34) 915495762-Ext.3005
> Tel:(+34) 913367366-Ext.3005
> ----------------------------------------------------------------
> 
> 
> -- 
> ----------------------------------------------------------------
> Centro de Cálculo         Depto. Ingeniería Sistemas Telemáticos
> E-mail: omar@dit.upm.es        Universidad Politécnica de Madrid
> Fax:(+34) 913367333                 E.T.S. Ing. Telecomunicación
> Tel:(+34) 915495700-Ext.3005                28040 Madrid (Spain)
> Tel:(+34) 915495762-Ext.3005
> Tel:(+34) 913367366-Ext.3005
> ----------------------------------------------------------------
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
