Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:56708 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932497Ab0DQARU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 20:17:20 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1O2vin-00072P-Jm
	for linux-nfs@vger.kernel.org; Sat, 17 Apr 2010 02:17:17 +0200
Received: from 66.49.167.64 ([66.49.167.64])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 17 Apr 2010 02:17:17 +0200
Received: from dennisn by 66.49.167.64 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 17 Apr 2010 02:17:17 +0200
To: linux-nfs@vger.kernel.org
From: Dennis Nezic <dennisn@dennisn.dyndns.org>
Subject: Re: NFS stops responding
Date: Fri, 16 Apr 2010 20:17:00 -0400
Message-ID: <20100416201700.215b0bea.dennisn@dennisn.dyndns.org>
References: <4BC62E38.3010704@wsi.com>
Content-Type: text/plain; charset=US-ASCII
In-Reply-To: <4BC62E38.3010704@wsi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Well I for one am convinced there is a bug either in the linux kernel,
or somewhere. I have a similar problem (I posted about it here on March
18 2010), where NFS activity very frequently hangs for several minutes,
for no good reason. (Changing the nfs mount option to "hard" should get
rid of the I/O Errors, but it's still incredibly frustrating/annoying
-- it will simply retry after precious minutes have been wasted, instead
of failing :b). My problems began ONLY after I upgraded my server's
kernel. When did yours begin?

I have noticed that when a client hangs, other clients still work --
ie. the nfs server is still (sortof) working -- so I imagine there is
something wrong with the client too?

I usually get things working by restarting nfs on my server, and
waiting a few seconds. (I don't need to remount on my clients.)

I have also noticed similar problems while transferring large files
over scp (the transfers stall), both to and from my server (does scp'ing
large files work for you?), and even with large files over http.
(Interestingly, server-to-client scp transfers last for much longer
than client-to-server transfers -- ie. ~90MB for the former versus
~10MB for the latter.)

If you ever get anywhere with your puzzle, don't forget to TELL US!!
Good luck :)


On Wed, 14 Apr 2010 17:06:00 -0400, Michael O'Donnell wrote:
> I've run out of clues (EBRAINTOOSMALL) trying to solve an NFS puzzle
> at a remote customer site and I'm hoping to get unstuck.
> 
> Symptoms: after approx 1 hour of apparently normal behavior,
> operations like 'df -k' or 'ls -l' hang for minutes at a time and
> then fail with I/O errors on any of three machines when such
> operations refer to NFS mounted directories.
> 
> The 3 machines have NFS relationships thus:
> 
>    A mounts approx 6             directories from B (A->B)
>    B mounts approx 6 (different) directories from A (B->A)
>    C mounts approx 6 directories from A (C->A) (same dirs as in B->A)
>    C mounts approx 6 directories from B (C->B) (same dirs as in A->B)
> 
> Weirdly, when the failure occurs, doing this on all 3 machines:
> 
>     umount -f -l -a -t nfs
> 
> ...followed by this:
> 
>     mount -a -t nfs
> 
> ...on all 3 gets things unstuck for another hour.  (?!?!)
> 
> All three systems (HP xw8600 workstations) started life running
> bit-for-bit identical system images (based on x86_64 CentOS5.4)
> and only differ in which of our apps and configs are loaded.
> 
> Kernel is 2.6.18-92.1.17.el5.centos.plus
> 
> All 3 systems were previously running an old RHEL3 distribution on the
> same hardware with no problems.
> 
> Each machine has only two interfaces defined: 'lo' and 'eth0' with the
> latter being a wired gigE.
> 
> All MTUs are the standard 1500; nothing like jumbo packets in use.
> 
> Each machine has a statically assigned address - no DHCP in play.
> 
> All systems are connected via a common Dell 2608 PowerConnect switch
> that's believed (but not conclusively proven) to be functioning
> properly.
> 
> I've tried specifying both UDP and TCP in the fstab lines.
> 
> We're using the default NFSv3.
> 
> I've disabled selinux.
> 
> The output of 'iptables -L' for all rules in all
> (filter,nat,mangle,raw) chains on all machines shows as '(policy
> ACCEPT)'.
> 
> Each machine always shows the same 3 routes when queried via 'route
> -n'.
> 
> The ARP caches show nothing unexpected on any machine.
> 
> These commands:
> 
>     service nfs status ; service portmap status
> 
> ...indicate nominal conditions (all expected daemons reported running)
> when things are working but also when things are b0rken.
> 
> There wasn't anything very informative in /var/log/messages with the
> default debug levels but messages are now accumulating there at
> firehose rates because I enabled debug for everything, thus:
> 
>     for m in rpc nfs nfsd nlm; do rpcdebug -m $m -s all; done
> 
> After machine A exhibited the problem I *think* I see evidence in the
> /var/log/messages that the NFS client code believes it never got a
> response from the server (B) to some NFS request, so it retransmits
> the request and (I think) it then concludes that the retransmitted
> request also went unanswered so the operation is errored out.
> 
> I'm capturing dumps of Enet traffic on the client and server boxes at
> the remote customer site thus:
> 
>     dumpcap -i eth0 -w /tmp/`hostname`.pcap
> 
> ...and then copying the dumps back to HQ where I feed them to
> Wireshark. I am not (yet?) rigged up so I can sniff traffic from an
> objective third party.
> 
> When I display the client traffic log file with Wireshark, it
> (apparently) confirms that the client did indeed wait a while and
> then (apparently) retransmitted the NFS request.  The weird thing is
> that Wireshark analysis of corresponding traffic on the server shows
> the first request coming in and being replied to immediately, then we
> later see the retransmitted request arrive and it, too, is promptly
> processed and the response goes out immediately.  So, if I'm reading
> these tea leaves properly it's as if that client lost the ability to
> recognize the reply to that request.  [?!]
> 
> But, then, how could it be that all 3 machines seem to get into this
> state at more or less the same time?  and why would unmounting and
> remounting all NFS filesystems then "fix" it?   Aaaiiieeee!!!
> 
>   [ Unfortunately, this problem is only occuring at the one
>     customer site and can't be reproduced in-house, so unless
>     I can find a way to first sanitize the logs I may not be
>     permitted (lucky you!) to publish them here...       >-/  ]
> 
> A Wireshark rendering of relevant traffic while observing as
> 'ls -l mountPoint' on the client hangs and then return with 'I/O
> Error' :
> 
>    On CLIENT A:
>    #     Time       SRC DST PROT INFO
>    1031  1.989127   A   B   NFS  V3   GETATTR Call, FH:0x70ab15aa
>    4565  10.121595  B   A   NFS  V3   GETATTR Call, FH:0x00091508
>    4567  10.124981  A   B   NFS  V3   FSSTAT  Call, FH:0x17a976a8
>    4587  10.205087  A   B   NFS  V3   GETATTR Call, FH:0xf2c997c8
>    29395 61.989380  A   B   NFS  V3   GETATTR Call, FH:0x70ab15aa
> [retransmission of #1031] 66805 130.119722 B   A   NFS  V3   GETATTR
> Call, FH:0x0089db89 66814 130.124815 A   B   NFS  V3   FSSTAT  Call,
> FH:0x18a979a8 97138 181.989898 A   B   NFS  V3   GETATTR Call,
> FH:0x70ab15aa
> 
>    On SERVER B:
>    #     Time       SRC DST PROT INFO
>    677   1.342486   A   B   NFS  V3   GETATTR Call, FH:0x70ab15aa
>    4045  9.474848   B   A   NFS  V3   GETATTR Call, FH:0x00091508
>    4047  9.478325   A   B   NFS  V3   FSSTAT  Call, FH:0x17a976a8
>    4076  9.558433   A   B   NFS  V3   GETATTR Call, FH:0xf2c997c8
>    28625 61.342630  A   B   NFS  V3   GETATTR Call, FH:0x70ab15aa
> [retransmission of #677] 61257 129.472779 B   A   NFS  V3   GETATTR
> Call, FH:0x0089db89 61268 129.477965 A   B   NFS  V3   FSSTAT  Call,
> FH:0x18a979a8 87631 181.342989 A   B   NFS  V3   GETATTR Call,
> FH:0x70ab15aa
> 
> I don't really trust my interpretation of what Wireshark is showing
> me but, if I'm correct, the problem is not that we stop seeing return
> traffic from the server, it's more that the client stops making sane
> decisions in response when it arrives.  Maybe the packets aren't
> getting all the way back up the stack to be processed by the client
> code?
> 
> All other network plumbing appears to be in working order while the
> problem is occurring - I can connect from one system to another at
> will via SSH, rsync, HTTP, ping, etc.
> 
> I'd love to blame the switch, and I just acquired a brand new one to
> use as an experimental replacement for the one currently deployed.
> I'll be ecstatic if that fixes thing, though I'm not optimistic.
> 
> I'm assuming this mess is somehow due either to a site-specific botch
> in something like a config file or else maybe that switch.  We have
> a number of other customers with identical rigs (same software on the
> same workstations) that work fine, so (hoping!)  it seems unlikely
> that there's an inherent flaw in the SW or HW...
> 
> Analysis is awkward because the customers in question are trying to
> make what use they can of the machines even as these problems are
> ocurring around them, so reboots and other dramatic acts have to be
> scheduled well in advance.
> 
> I know of no reasons in principle why two machines can't
> simultaneously act as NFS clients and NFS servers - are there any?
> AFAIK the two subsystems are separate and have no direct dependencies
> or interactions; does anybody know otherwise?  Yes, I'm aware that
> some systems can be misconfigured such that cross-mounting causes
> problems at boot-time as they each wait for the other's NFS server to
> start, but this ain't that...
> 
> Any help or clues gratefully accepted...
> 
>    --M
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in the body of a message to
> majordomo@vger.kernel.org More majordomo info
> at  http://vger.kernel.org/majordomo-info.html
> 

