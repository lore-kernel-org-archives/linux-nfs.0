From: gb <bakerg3@yahoo.com>
Subject: NFS over TCP test results / NetApp / Linux
Date: Wed, 23 Apr 2003 20:34:13 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030424033413.85788.qmail@web41311.mail.yahoo.com>
Reply-To: greg@bakers.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web41311.mail.yahoo.com ([66.218.93.60])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198XV4-0005ts-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 20:34:18 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


> Subject: Re: [NFS] NFS over TCP test results
> Date: Wed, 23 Apr 2003 18:37:37 -0500
> To: Lever, Charles <XXXCharles.Lever@netapp.comXXX>,
> Trond Myklebust <XXXtrond.myklebust@fys.uio.noXXX>
> References:
>
<6440EA1A6AA1D5118C6900902745938E07D5555A@black.eng.netapp.com>
> 
> 
> 
> Charles / Trond,
> 
> I've done my best to respond to your comments and
> suggestions.
> 
> Thanks, your expertise is much appreciated.
> 
> >>The latest kernel available (2.4.21pre7 + patches
> via
> >>Chuck Lever of NetApp) do not appear to fix the
> >>problem.
> > 
> > i don't know which patches you're referring to. 
> can
> > you provide some URLs?  have you reproduced this
> with
> > unmodified 2.4.21-pre7 ?  at least one of my
> patches
> > removes the "can't get request slot" message, so
> if
> > you say you see that message in your kernel log,
> > "you got some 'splaining to do."
> 
> the test pool of systems were:
> 
> 2.4.16 unpatched   (where we were)
> 2.4.18 unpatched   (where we upgraded to)
> 2.4.21pre7 patched (below)
>      + checked to see if problem was solved w/
> switch from iovec to pages
>      + linux-2.4.21-01-call_reserve1.dif
>      + linux-2.4.21-02-call_reserve2.dif
>      + linux-2.4.21-03-noac.dif
>      + linux-2.4.21-07-rdplus.dif
>      + linux-2.4.21-14-xprt_fixes.dif
> 
> Patches are from:
> 
> The 'can't get request slot' was seen only on 2.4.18
> tcp-nfs clients.  The
> 'nfs server not responding' was seen on all.  Since
> I either had entire
> pools of 2.4.18 or a mix of 2.4.18 and
> 2.4.21pre7+patches it's my mistake
> for mixing the errors between the two in my original
> email.
> 
> >>Until this critical problem is resolved, it is a
> moot
> >>point to argue the advantages of tcp-nfs vs.
> udp-nfs
> >>regarding network traffic or CPU usage.
> > 
> > this is a little far fetched.  NFS over TCP works
> > very well in many environments.  NFS over UDP
> fails
> > very quickly in many environments.  it is well
> > known that some experimentation is required to
> > determine which of TCP or UDP is right to use
> > in any environment.
> 
> The 'moot point' comment was directed to my peers at
> who received the
> email via a different channel in relevance to our
> environment, not
> necessarily at the linux-nfs community at large.  I
> forgot to edit some
> points when forwarding my original email.  Sorry!
> 
> > now for some detailed criticism:
> > 
> >  +  you don't list your complete set of mount
> options.
> 
> for tcp-nfs mounts:
> 
> sphere:/vol/vol7/7/admin-test1 /u/admin-test1 nfs
>
rw,v3,rsize=32768,wsize=32768,hard,intr,tcp,lock,addr=sphere
> 0 0
> vger:/vol/vol2/admin-test2 /u/admin-test2 nfs
>
rw,v3,rsize=32768,wsize=32768,hard,intr,tcp,lock,addr=vger
> 0 0
> wopr:/vol/vol4/admin-test3 /u/admin-test3 nfs
>
rw,v3,rsize=32768,wsize=32768,hard,intr,tcp,lock,addr=wopr
> 0 0
> 
> for udp-nfs mounts:
> 
> sphere:/vol/vol7/7/admin-test1 /u/admin-test1 nfs
>
rw,v3,rsize=32768,wsize=32768,hard,intr,udp,lock,addr=sphere
> 0 0
> vger:/vol/vol2/admin-test2 /u/admin-test2 nfs
>
rw,v3,rsize=32768,wsize=32768,hard,intr,udp,lock,addr=vger
> 0 0
> wopr:/vol/vol4/admin-test3 /u/admin-test3 nfs
>
rw,v3,rsize=32768,wsize=32768,hard,intr,udp,lock,addr=wopr
> 0 0
> 
> >  +  you don't itemize your client hardware (SMP? 
> NIC
> >     hardware?  RAM size?  CPU speed?).
> 
> 12/14 of the pool are:
> 
> Tyan Tiger MP, bios v2.13
> 2x2000Ghz Athlon MP (I forget the PR rating)
> onboard 3c59x NIC loaded via module 3c59x
> 2-3GB RAM, ECC Srub Turned on
> 
> 2/14 of the pool are:
> 
> Abit KT7A (Via KT133A rev chipset) MB, bios unknown
> 1x1250Mhz Athlon XP
> Intel eepro100 NIC loaded via module eepro100
> 512-1GB of RAM
> 
> >  +  you don't provide any network traces or
> analysis.
> 
> Network trace attached from typical session.  I
> didn't provide them at first because I 
> didn't want to swamp the list with Mb of attachments
> until I knew if this was known
> (search of archives didn't seem to indicate this) or
> who was interested.
> 
> The interesting stuff begins to happen
> (valk101.wopr) around packet #22327.  The NFS 
> server (wopr, NetApp 6.2.2) begins to decrease the
> window size it's advertising. 
> Eventually the window size advertised by wopr is set
> to 0 (#22354).
> 
> Not that there's anything wrong with this (p323
> TCP/IP Illustrated Vol I) but as time goes 
> by and the client is sending window probes the filer
> continues to respond with a win=0.
> 
> I have similiar traces from the other NetApps
> (sphere, vger) and can include them if 
> you're interested.  They're a bit larger though.
> 
> Stopping the other clients in the test does not
> change the filers behavior.
> 
> All filers in the test are running 6.2.2 or 6.2.2R2.
>  It is unknown if a different version 
> of SnapOS? exhibits the same problem.
> 
> >  +  you don't provide the output of "nfsstat -c"
> or
> >     "netstat -s".
> 
> After the "hang" occurs we have something along the
> lines of:
> 
> valk101:
> 
> [root@valk101 root]# nfsstat -s
> (nothing, this is a NFS client-only, no exports)
> 
> [root@valk101 root]# nfsstat -c
> Client rpc stats:
> calls      retrans    authrefrsh
> 14390      25         0
> Client nfs v2:
> null       getattr    setattr    root       lookup  
>   readlink
> 0       0% 0       0% 0       0% 0       0% 0      
> 0% 0       0%
> read       wrcache    write      create     remove  
>   rename
> 0       0% 0       0% 0       0% 0       0% 0      
> 0% 0       0%
> link       symlink    mkdir      rmdir      readdir 
>   fsstat
> 0       0% 0       0% 0       0% 0       0% 0      
> 0% 0       0%
> 
> Client nfs v3:
> null       getattr    setattr    lookup     access  
>   readlink
> 0       0% 2250   15% 4       0% 787     5% 6799  
> 47% 33      0%
> read       write      create     mkdir      symlink 
>   mknod
> 230     1% 4147   28% 3       0% 0       0% 0      
> 0% 0       0%
> remove     rmdir      rename     link       readdir 
>   readdirplus
> 3       0% 0       0% 0       0% 0       0% 0      
> 0% 20      0%
> fsstat     fsinfo     pathconf   commit
> 58      0% 56      0% 0       0% 0       0%
> 
> [root@valk101 root]# vmstat 2 5
> procs -----------memory---------- ---swap--
> -----io---- --system-- ----cpu----
>    r  b   swpd   free   buff  cache   si   so    bi 
>   bo   in    cs us sy id wa
>    0  4      0 1806808  16124 184656    0    0     2
>    25   75    31  0  0 100  0
>    0  4      0 1806792  16132 184656    0    0     0
>    82  129    18  0  0 100  0
>    0  4      0 1806788  16132 184656    0    0     0
>     0  149   126  0  0 100  0
>    0  4      0 1806792  16132 184656    0    0     0
>     0  109     7  0  0 100  0
>    0  4      0 1806784  16140 184656    0    0     0
>    22  117    14  0  0 100  0
> 
> root      1875  0.0  0.0  1312  508 ?        D   
> 16:39   0:00 df -k
> root      1935  0.0  0.0  1312  508 ?        D   
> 16:41   0:00 df -k
> root      1956  0.0  0.0  1872  832 ?        D   
> 16:42   0:00 /bin/sh
> greg      2123  0.0  0.0  2316 1356 ?        D   
> 16:46   0:00 /bin/bash --login
> 
> Where process 2123 was a 'cd /u/admin-test1' (on NFS
> server sphere) we have:
> 
> [root@valk101 log]# cat /proc/2123/status
> Name:   bash
> State:  D (disk sleep)
> Tgid:   2123
> Pid:    2123
> PPid:   1
> TracerPid:      0
> Uid:    30535   30535   30535   30535
> Gid:    30102   30102   30102   30102
> FDSize: 256
> Groups: 30102 30101
> VmSize:     2316 kB
> VmLck:         0 kB
> VmRSS:      1356 kB
> VmData:      344 kB
> VmStk:        20 kB
> VmExe:       508 kB
> VmLib:      1376 kB
> SigPnd: 0000000000020001
> SigBlk: fffffffffffffeff
> SigIgn: 0000000000384004
> SigCgt: 000000004b813efb
> CapInh: 0000000000000000
> CapPrm: 0000000000000000
> CapEff: 0000000000000000
> 
> >  +  how are your Ethernet switches connected to
> each
> >     other?  do you have switch statistics that
> show
> >     the switches are behaving?  are the GbE links
> >     configured for full duplex and full flow
> control?
> 
> valk094: 00:E0:81:24:89:7A 159-cat03 port 5/43
> valk104: 00:E0:81:24:87:72 159-cat03 port 4/5
> valk101: 00:E0:81:24:88:8C 159-cat03 port 4/2
> 
> Each client sets the duplex during startup using
> mii-diag:
> /usr/sbin/mii-diag -F 100baseTX-FD eth0
> 
> Each client switchport is hard coded to 100-full.
> 
> (I know all the above are on the same switch.  If
> you'd like me to submit
> other hosts I can do so.  All other exhibit the same
> problems as these,
> but I have remote console access to the valk*
> systems which makes it
> easier to run tests on).
> 
> I don't have permissions to clear the counters on
> the ports, but the
> *-Err, *-Collision, and UnderSize counters are not
> increasing during the test.
> 
> Uplink from 159-cat03 (client switch) to ftf-cat01
> (root switch) is:
> 1/1 connected  trunk      normal   full  1000
> 1000BaseSX
> 
> Uplink from filers to ftf-cat01 (root switch) are:
> 
> sphere: 5/15 Sphere connected  18 full  1000
> 1000BaseSX FlowControl on
> vger: 5/10 Vger connected  18 full  1000 1000BaseSX
> FlowControl on
> wopr: 5/2 Wopr connected  18 full  1000 1000BaseSX
> FlowControl on
> 
> >  +  when you say "remote directories were
> unavailable"
> >     do you mean other processes on the stuck
> client
> >     couldn't access files in that directory, or
> other
> >     clients that work OK could not access the
> directories?
> 
> Other processes on the stuck client couldn't access
> that directory, or
> files within it.  New mounts from clients outside of
> the pool functioned
> properly.
> 
> >  +  can you explain why the problem arises in
> tests
> >     A and D, but not in B or C?
> 
> I made the haphazard proposal that a certain tcp-nfs
> load introduces the
> problem, which is why I included NetApp in the
> discusion.  A smaller
> amount of tcp-nfs clients in a pool (case B) or no
> tcp-nfs clients in a pool
> (case D) do not cause the behavior "remote
> directories unavailable".
> 
> > let's take this off the list until we have less
> conjecture
> > and more facts.
> 
> Sounds good to me.
> 
> Let me know if there's anything else I can provide
> or help with.
> 
> Thanks,
> 
> --Greg


> ATTACHMENT part 2 application/x-bzip2
name=valk101.wopr.bz2



__________________________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo
http://search.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
