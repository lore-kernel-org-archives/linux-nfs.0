From: Fabrizio Nesti <nesti@medialab.sissa.it>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Tue, 18 Feb 2003 16:47:47 +0100 (MET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.40.0302181629160.28386-100000@bodoni>
References: <3E525176.13DFBBA1@amis.com>
Reply-To: Fabrizio Nesti <nesti@medialab.sissa.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Powell <lakerfaniam2@yahoo.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from didot.sissa.it ([147.122.2.50])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lA2I-0003ph-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 07:51:58 -0800
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: <3E525176.13DFBBA1@amis.com>
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

Thanks for the replies, but:

yes,
- the UDP server is a (SCSI) 4disks RAID5. Very fast.
- The TCP (experimental) server is all the same very fast (dma enabled).
- Typical time for local operation (the same tar xf) is 1 sec or less.

solaris is : SunOS 5.8 Generic_108528-09 sun4u sparc SUNW,Ultra-5_10
linux are :
  udp server: Linux 2.4.18-24.8.0smp #1 SMP i686 i686
  tcp server: Linux 2.4.20 i686 athlon

Plain read or write (dd) is quite satisfactory, so it seems that problems
arise with many near reads and writes (like tar, cvs etc).
Also, it seems that we have no retransmission problems.
(see below nfsstat -c on solaris).

Puzzled.

Thanks to all,
cheers,
Fabrizio

PS: root@caslon:/root$ nfsstat -c

Client rpc:
Connection oriented:
calls        badcalls     badxids      timeouts     newcreds     badverfs
10994822     1645         30           16           0            0
timers       cantconn     nomem        interrupts
0            1598         0            29
Connectionless:
calls        badcalls     retrans      badxids      timeouts     newcreds
37885148     10303        6058         238          16180        0
badverfs     timers       nomem        cantsend
0            4267         0            0

Client nfs:
calls        badcalls     clgets       cltoomany
48204358     218          48204358     28
Version 2: (4019 calls)
null         getattr      setattr      root         lookup       readlink
0 0%         3909 97%     42 1%        0 0%         55 1%        6 0%
read         wrcache      write        create       remove       rename
0 0%         0 0%         0 0%         0 0%         0 0%         0 0%
link         symlink      mkdir        rmdir        readdir      statfs
0 0%         0 0%         0 0%         0 0%         6 0%         1 0%
Version 3: (48171346 calls)
null         getattr      setattr      lookup       access       readlink
0 0%         18461695 38% 482002 1%    8829223 18%  7849906 16%  16660 0%
read         write        create       mkdir        symlink      mknod
7750211 16%  3143812 6%   244856 0%    25973 0%     8847 0%      0 0%
remove       rmdir        rename       link         readdir      readdirplus
228254 0%    18425 0%     13163 0%     14493 0%     259741 0%    361588 0%
fsstat       fsinfo       pathconf     commit
50919 0%     740 0%       2075 0%      408763 0%

Client nfs_acl:
Version 2: (1 calls)
null         getacl       setacl       getattr      access
0 0%         0 0%         0 0%         1 100%       0 0%
Version 3: (28992 calls)
null         getacl       setacl
0 0%         28992 100%   0 0%



On Tue, 18 Feb 2003, Eric Whiting wrote:

> Have you verified that your storage is properly setup? Is it IDE/SCSI/RAID? IDE
> storage with DMA disabled will cause terrible performance. Please verify disk
> speed on local writes and make sure they are 'faster' than the network.
>
> What version of SOlaris are you running? Solaris 8 and newer has a lot of NFS
> fixes...
>
> We are getting good NFS numbers with 2.4.20 UDP NFS servers against solaris [89]
> clients.
>
> eric
>
> Fabrizio Nesti wrote:
> >
> > Sorry,
> > the reason to switch to TCP was exactly the same: poor nfs performance as
> > seen from any solaris client. And by poor I mean three-five times slower.
> >
> > The same "tar xf" (a typical high load r/w usage) gives
> >
> >                      linux server           solaris server
> > linux   client      1 sec (udp)(caching?)    8 sec (for both tcp and udp)
> > solaris client      22/40 sec (tcp/udp)      10/8 sec (tcp/udp)
> >
> > We worry about these ^^^  figures, since we bought a new linux server
> > to switch to, and we have some solaris clients.
> >
> > Since solaris nfs clients sseems to prefer TCP, and following some messages
> > on the list, we tried that. (Even tuning can not improve this situation).
> > Is there something wrong we are doing or we have to switch back to soalris
> > server?
> >
> > Thanks again,
> > Fabrizio Nesti
> >
> > On Mon, 17 Feb 2003, Alan Powell wrote:
> >
> > > 8192 block size is a Linux daemon limitation. Also,
> > > don't switch to TCP unless you need to. UDP will be
> > > faster if you have a decent network. Revert back to
> > > UDP, and on the client side, run "nfsstat -c" and
> > > monitor the number of retransmissions. If that number
> > > doesn't increase, you have a clean network, and you
> > > should stay on UDP.
> > >
> > >
> > > --- Fabrizio Nesti <nesti@medialab.sissa.it> wrote:
> > > > Hello to everybody.
> > > > we are reporting a very low performance for nfs
> > > > access from Solaris clients
> > > > to the linux nfs server on RH8.0. We thought it was
> > > > udp and upgraded to
> > > > kernel 2.4.20.
> > > >
> > > > Now the performance is still low, compared to a
> > > > solaris server:
> > > >     # time gtar xf /var/tmp/cvs-1.11.5.tar
> > > >     Writing on Linux_2.4.20> real    0m22.132s
> > > >     Writing on Solaris_8>    real    0m7.174s
> > > >
> > > > Both filesystems are mounted with
> > > > proto=tcp,rsize=32768,wsize=32768.
> > > > Snooping the traffic however, it appears that the
> > > > linux server is not
> > > > serving with size=32768, but with a maximum size of
> > > > 8192.
> > > >
> > > > - Is there a reson for this?
> > > > - May this be the reason for the poor performance
> > > > above?
> > > >
> > > > Thanks in advance,
> > > > Fabrizio Nesti
> > > >
> > > >
> > > > PS: Some snoop traffic:
> > > > ...
> > > >   solaris -> linux  NFS C CREATE3 FH=884D
> > > > (EXCLUSIVE) check_cvs.in
> > > > linux -> solaris    NFS R CREATE3 OK FH=174A
> > > >  solaris -> linux   NFS C SETATTR3 FH=174A
> > > > linux -> solaris    NFS R SETATTR3 OK
> > > >   solaris -> linux  NFS C WRITE3 FH=174A at 0 for
> > > > 8192 (ASYNC)
> > > >   solaris -> linux  TCP D=2049 S=793 Ack=633960980
> > > > Seq=849797604 Len=1460
> > > >   solaris -> linux  TCP D=2049 S=793 Ack=633960980
> > > > Seq=849799064 Len=1460
> > > >   solaris -> linux  TCP D=2049 S=793 Ack=633960980
> > > > Seq=849800524 Len=1460
> > > >   solaris -> linux  TCP D=2049 S=793 Ack=633960980
> > > > Seq=849801984 Len=1460
> > > >   solaris -> linux  TCP D=2049 S=793 Ack=633960980
> > > > Seq=849803444 Len=1056
> > > > linux -> solaris    TCP D=793 S=2049 Ack=849804500
> > > > Seq=633960980 Len=0
> > > > ...
> > > >
> > > >
> > > >
> > > >
> > > -------------------------------------------------------
> > > > This sf.net email is sponsored by:ThinkGeek
> > > > Welcome to geek heaven.
> > > > http://thinkgeek.com/sf
> > > > _______________________________________________
> > > > NFS maillist  -  NFS@lists.sourceforge.net
> > > > https://lists.sourceforge.net/lists/listinfo/nfs
> > >
> > >
> > > __________________________________________________
> > > Do you Yahoo!?
> > > Yahoo! Shopping - Send Flowers for Valentine's Day
> > > http://shopping.yahoo.com
> > >
> >
> > -------------------------------------------------------
> > This sf.net email is sponsored by:ThinkGeek
> > Welcome to geek heaven.
> > http://thinkgeek.com/sf
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
>





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
