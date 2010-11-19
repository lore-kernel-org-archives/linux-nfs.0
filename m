Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:33315 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755518Ab0KSW6F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Nov 2010 17:58:05 -0500
Date: Fri, 19 Nov 2010 14:58:03 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS client/sunrpc getting stuck on 2.6.36
Message-ID: <20101119225803.GC3270@hostway.ca>
References: <20101111023520.GH16939@hostway.ca> <1289452967.4062.10.camel@heimdal.trondhjem.org> <20101119202004.GA3270@hostway.ca> <1290201888.3135.61.camel@heimdal.trondhjem.org> <20101119220356.GB3270@hostway.ca> <1290205039.3135.74.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1290205039.3135.74.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Nov 19, 2010 at 05:17:19PM -0500, Trond Myklebust wrote:

> On Fri, 2010-11-19 at 14:03 -0800, Simon Kirby wrote:
> > On Fri, Nov 19, 2010 at 04:24:48PM -0500, Trond Myklebust wrote:
> > 
> > > On Fri, 2010-11-19 at 12:20 -0800, Simon Kirby wrote:
> > > > On Thu, Nov 11, 2010 at 01:22:47PM +0800, Trond Myklebust wrote:
> > > > 
> > > > > On Wed, 2010-11-10 at 18:35 -0800, Simon Kirby wrote:
> > > > > > Still seeing all sorts of boxes fall over with 2.6.35 and 2.6.36 NFS.
> > > > > > Unfortunately, it doesn't happen all the time...only certain load
> > > > > > patterns seem to start it off.  Once it starts, I can't find a way to
> > > > > > make it recover without rebooting.
> > > > > >...
> > > > > > NFS: permission(0:4c/5284877), mask=0x1, res=0
> > > > > > NFS: revalidating (0:4c/3247737045)
> > > > > > 
> > > > > > 900ms matches the probably-silly nfs mount settings we're currently using:
> > > > > > 
> > > > > > rw,hard,intr,tcp,timeo=9,retrans=3,rsize=8192,wsize=8192
> > > > > > 
> > > > > > Full kernel log here: http://0x.ca/sim/ref/2.6.36_stuck_nfs/
> > > > > 
> > > > > timeo=9 is a completely insane retransmit value for a tcp connection.
> > > > > 
> > > > > Please use the default timeo=600, and all will work correctly.
> > > > 
> > > > Ok, so, we were running with timeo=300 instead on a number of servers,
> > > > and we were still seeing the problem on 2.6.36.  I've uploaded a new
> > > > kernel log (lsh1051) here:
> > > > 
> > > > 	http://0x.ca/sim/ref/2.6.36_stuck_nfs/
> > > > 
> > > > The log starts out with the hung task warnings occurring after
> > > > otherwise-normal operation.  Once I noticed, I set rpc/nfs_debug to 1,
> > > > and then later set it to 255.
> > > 
> > > Were the NFS servers hung at this point? If so, then that probably
> > > suffices to explain the hung task warnings (which would be false
> > > positives) as being due to the page cache waiting to lock pages on which
> > > I/O is being performed.
> > 
> > Nope...Many other NFS clients did not notice anything, and there were no
> > obvious problems on any NFS server.  This was only affecting two clients
> > at the same time, but we had a limited LVS pool pointing at them at the
> > time to try to isolate load patterns that might be tickling the issue.
> 
> So what were all the 
> 
> 'lockd: server 10.10.52.xxx not responding, still trying'
> 
> messages all about? There were quite a few of them for a number of
> different servers in the moments leading up to the hang. Could it be a
> problem with the switch these clients are attached to?

If it were a switch problem, would we see port 2049 socket backlogs with
netstat -tan or ss -tan?  I haven't seen this at all when the problem
occurs.  All of the sockets are idle (and usually it seems to close them
all except the one server that all of the slots are stuck on).  tcpdump
shows no problems, just very slow requests rates that match the rpc/nfs
debugging.

If the rpc slots are stuck full, would that cause lockd to print those
timeouts?

Actually, another one just got stuck right now:

[root@lsh1003:/root]# dmesg|tail
lockd: server 10.10.52.227 not responding, still trying
lockd: server 10.10.52.155 not responding, still trying
lockd: server 10.10.52.163 not responding, still trying
lockd: server 10.10.52.155 not responding, still trying
lockd: server 10.10.52.150 not responding, still trying
lockd: server 10.10.52.151 not responding, still trying
lockd: server 10.10.52.162 not responding, still trying
lockd: server 10.10.52.155 not responding, still trying
lockd: server 10.10.52.163 not responding, still trying
lockd: server 10.10.52.155 not responding, still trying
[root@lsh1003:/root]# netstat -tano | grep 2049
tcp        0      0 10.10.52.13:809         10.10.52.222:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:826         10.10.52.163:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:724         10.10.52.230:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:784         10.10.52.228:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:786         10.10.52.155:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:672         10.10.52.224:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:948         10.10.52.227:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:925         10.10.52.150:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:773         10.10.52.225:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:742         10.10.52.162:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:788         10.10.52.151:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:733         10.10.52.160:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:1010        10.10.52.15:2049        ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:854         10.10.52.221:2049       ESTABLISHED off (0.00/0/0)
tcp        0      0 10.10.52.13:892         10.10.52.229:2049       ESTABLISHED off (0.00/0/0)
[root@lsh1003:/root]# netstat -tano | grep 2049
[root@lsh1003:/root]# tcpdump  -i any -n port 2049 -s 9999
tcpdump: WARNING: Promiscuous mode not supported on the "any" device
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 9999 bytes
16:37:35.391957 IP 10.10.52.13.603423014 > 10.10.52.150.2049: 100 getattr fh Unknown/01000600B1C2A7D11304420481B0C6A6D63811CC000000000000000000000000
16:37:35.392129 IP 10.10.52.150.2049 > 10.10.52.13.603423014: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
16:37:35.392157 IP 10.10.52.13.925 > 10.10.52.150.2049: . ack 185054172 win 3078 <nop,nop,timestamp 124239060 3176255375>
16:37:35.392295 IP 10.10.52.13.620200230 > 10.10.52.150.2049: 104 access fh Unknown/01000600B1C2A7D11304420481B0C6A6D63811CC0000001F000000004CE6FC2F 001f
16:37:35.392438 IP 10.10.52.150.2049 > 10.10.52.13.620200230: reply ok 124 access c 001f
16:37:35.392511 IP 10.10.52.13.636977446 > 10.10.52.150.2049: 148 lookup fh Unknown/01000600B1C2A7D11304420481B0C6A6D63811CC0000002C6E6673436865636B "nfsCheckTestFile.lsh1003.lsh.hostnameremoved"
16:37:35.392660 IP 10.10.52.150.2049 > 10.10.52.13.636977446: reply ok 240 lookup fh Unknown/01000601B1C2A7D11304420481B0C6A6D63811CC12000000142933E300000001
16:37:35.392701 IP 10.10.52.13.653754662 > 10.10.52.150.2049: 112 access fh Unknown/01000601B1C2A7D11304420481B0C6A6D63811CC12000000142933E30000002D 002d
16:37:35.392849 IP 10.10.52.150.2049 > 10.10.52.13.653754662: reply ok 124 access c 000d
16:37:35.392898 IP 10.10.52.13.670531878 > 10.10.52.150.2049: 136 setattr fh Unknown/01000601B1C2A7D11304420481B0C6A6D63811CC12000000142933E300000000
16:37:35.393067 IP 10.10.52.150.2049 > 10.10.52.13.670531878: reply ok 148 setattr
16:37:35.429871 IP 10.10.52.13.925 > 10.10.52.150.2049: . ack 637 win 3078 <nop,nop,timestamp 124239070 3176255375>
16:37:36.393758 IP 10.10.52.13.2386403 > 10.10.52.151.2049: 100 getattr fh Unknown/010006004828B5EEFFF84A13B9DD0D3DCC3F0F130000000000000000C8533CC5
16:37:36.393924 IP 10.10.52.151.2049 > 10.10.52.13.2386403: reply ok 116 getattr DIR 40751 ids 0/0 sz 4096
16:37:36.393954 IP 10.10.52.13.788 > 10.10.52.151.2049: . ack 1968150002 win 7953 <nop,nop,timestamp 124239311 3336236361>
16:37:36.394034 IP 10.10.52.13.19163619 > 10.10.52.151.2049: 104 access fh Unknown/010006004828B5EEFFF84A13B9DD0D3DCC3F0F130000001F000000004CE6FC30 001f
16:37:36.394179 IP 10.10.52.151.2049 > 10.10.52.13.19163619: reply ok 124 access c 001f
16:37:36.394238 IP 10.10.52.13.35940835 > 10.10.52.151.2049: 148 lookup fh Unknown/010006004828B5EEFFF84A13B9DD0D3DCC3F0F130000002C6E6673436865636B "nfsCheckTestFile.lsh1003.lsh.hostnameremoved"
16:37:36.394400 IP 10.10.52.151.2049 > 10.10.52.13.35940835: reply ok 120 lookup ERROR: No such file or directory
16:37:36.394465 IP 10.10.52.13.52718051 > 10.10.52.151.2049: 180 create fh Unknown/010006004828B5EEFFF84A13B9DD0D3DCC3F0F130000002C6E6673436865636B "nfsCheckTestFile.lsh1003.lsh.hostnameremoved"
16:37:36.394637 IP 10.10.52.151.2049 > 10.10.52.13.52718051: reply ok 272 create fh Unknown/010006014828B5EEFFF84A13B9DD0D3DCC3F0F130D000000498FBC9300000001
16:37:36.433868 IP 10.10.52.13.788 > 10.10.52.151.2049: . ack 517 win 7953 <nop,nop,timestamp 124239321 3336236361>
16:37:37.395911 IP 10.10.52.13.2628690491 > 10.10.52.162.2049: 100 getattr fh Unknown/01000600BEEAE54F02694FC9B8BEC5F023EBC250000000000000000000000000
16:37:37.396075 IP 10.10.52.162.2049 > 10.10.52.13.2628690491: reply ok 116 getattr DIR 40751 ids 0/0 sz 4096
16:37:37.396119 IP 10.10.52.13.742 > 10.10.52.162.2049: . ack 440239041 win 5348 <nop,nop,timestamp 124239561 1314678534>
16:37:37.396206 IP 10.10.52.13.2645467707 > 10.10.52.162.2049: 104 access fh Unknown/01000600BEEAE54F02694FC9B8BEC5F023EBC2500000001F000000004CE6FC31 001f
16:37:37.396371 IP 10.10.52.162.2049 > 10.10.52.13.2645467707: reply ok 124 access c 001f
16:37:37.396429 IP 10.10.52.13.2662244923 > 10.10.52.162.2049: 148 lookup fh Unknown/01000600BEEAE54F02694FC9B8BEC5F023EBC2500000002C6E6673436865636B "nfsCheckTestFile.lsh1003.lsh.hostnameremoved"
16:37:37.396571 IP 10.10.52.162.2049 > 10.10.52.13.2662244923: reply ok 240 lookup fh Unknown/01000601BEEAE54F02694FC9B8BEC5F023EBC25060000000231C4E0900000001
16:37:37.396617 IP 10.10.52.13.2679022139 > 10.10.52.162.2049: 112 access fh Unknown/01000601BEEAE54F02694FC9B8BEC5F023EBC25060000000231C4E090000002D 002d
16:37:37.396747 IP 10.10.52.162.2049 > 10.10.52.13.2679022139: reply ok 124 access c 000d
16:37:37.396787 IP 10.10.52.13.2695799355 > 10.10.52.162.2049: 136 setattr fh Unknown/01000601BEEAE54F02694FC9B8BEC5F023EBC25060000000231C4E0900000000
16:37:37.396926 IP 10.10.52.162.2049 > 10.10.52.13.2695799355: reply ok 148 setattr
16:37:37.433868 IP 10.10.52.13.742 > 10.10.52.162.2049: . ack 637 win 5348 <nop,nop,timestamp 124239571 131467853

Or do I need to tcpdump the some other dynamic rpc port?

> > > > Since several servers were stuck at the same time and we were losing
> > > > quorum, I decided to try something more drastic and booted into
> > > > 2.6.37-rc2-git3.  This kernel hasn't got stuck yet!  However, it's
> > > > spitting out some new errors which may be worth looking into:
> > > > 
> > > > [ 1574.088812] NFS: server 10.10.52.222 error: fileid changed
> > > > [ 1574.088814] fsid 0:18: expected fileid 0x4c081940, got 0x4c081950
> > > > [11340.409447] NFS: server 10.10.52.228 error: fileid changed
> > > > [11340.409450] fsid 0:45: expected fileid 0x696ff82, got 0x16a98bd7
> > > > [20832.579912] NFS: server 10.10.52.225 error: fileid changed
> > > > [20832.579914] fsid 0:2a: expected fileid 0x8c67ebab, got 0x8c6811e5
> > > > [32775.957351] NFS: server 10.10.52.230 error: fileid changed
> > > > [32775.957354] fsid 0:52: expected fileid 0x919041fd, got 0x93f1962d
> > > > 
> > > > These are also in the same kernel log.  The error code isn't new, so
> > > > something else seems to have changed to cause it.
> > > 
> > > These indicate server bugs: your failover event appears to have caused
> > > the inode numbers to have changed on a number of files. This is
> > > something that shouldn't happen in a normal NFS environment, and so the
> > > client prints out the above warnings...
> > 
> > There was no fail-over event on any NFS server for the last week, so
> > I'm not sure what would be causing this.  The IPs listed there are
> > running 2.6.30.10 with XFS-exported fses.
> > 
> > All of the other clients running 2.6.36 (another 20 or so boxes) with the
> > same NFS mounts are not logging any "fileid changed" messages.  The first
> > time I've seen this message is with this 2.6.37-rc2-git3 kernel.
> 
> The only change in 2.6.37-rcX I can think of that might have caused an
> issue here would be Bryan's readdir changes.
> 
> If you can reproduce the above error condition, then could you try
> turning off readdirplus (using the 'nordirplus' mount option) and seeing
> if that makes a difference?

Trying now with "nordirplus" on 2.6.37-rc2-git3...

Simon-
