From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.6.0 -- nfs client runs 15x faster if client app runs as
 root.
Date: Wed, 07 Jan 2004 14:00:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FFC7371.6279A9F6@amis.com>
References: <482A3FA0050D21419C269D13989C6113020AC9B6@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AeKn7-0005M8-OM
	for nfs@lists.sourceforge.net; Wed, 07 Jan 2004 13:00:37 -0800
Received: from p01m168.mxlogic.net ([66.179.109.168])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AeKn7-0001CZ-2M
	for nfs@lists.sourceforge.net; Wed, 07 Jan 2004 13:00:37 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

"Lever, Charles" wrote:
> 
> are you writing to a set-uid file?  in the normal user case,
> the SETATTR is required by Posix to unset the set-* bits on
> the file.

It is a 'bonnie' run.. This test simply creates a new file and writes/reads the
file.

I don't see any suid bits on these files.

I tried the same tests on a Solaris 9 nfs server. Same results.


eric


> > -----Original Message-----
> > From: Eric Whiting [mailto:ewhiting@amis.com]
> > Sent: Wednesday, January 07, 2004 3:14 PM
> > To: nfs@lists.sourceforge.net
> > Subject: [NFS] 2.6.0 -- nfs client runs 15x faster if client
> > app runs as
> > root.
> >
> >
> > My 2.6.0 nfs clients to a netapps 940 NFS server run very
> > differently depending
> > on who the user is. Both tcp and udp mounts seem to show the
> > same behavior. This
> > is very apparent when doing the bonnie putc() tests.
> >
> > nfsstat and tcpdump show a lot of extra setattr calls when
> > running as a normal
> > user. I assume this is the reason for the slowdown.
> >
> > Is there a fix? Or is this the way it is supposed to be?
> >
> > This is not how this same hardware acts in 2.4.23.
> >
> > Thanks,
> > eric
> >
> >
> >
> > Running as a 'user' doing bonnie putc()
> > Writing with putc()...  done:    802 kB/s  10.6 %CPU
> >
> > 13:06:15.841823 172.16.17.176.3073181638 > 172.16.32.90.2049:
> > 144 setattr [|nfs]
> > (DF)
> > 13:06:15.842024 172.16.32.90.2049 > 172.16.17.176.3073181638:
> > reply ok 144
> > setattr [|nfs]
> > 13:06:15.842361 172.16.17.176.3089958854 > 172.16.32.90.2049:
> > 648 write [|nfs]
> > (DF)
> > 13:06:15.842611 172.16.32.90.2049 > 172.16.17.176.3089958854:
> > reply ok 160 write
> > [|nfs]
> > 13:06:15.842880 172.16.17.176.3106736070 > 172.16.32.90.2049:
> > 144 setattr [|nfs]
> > (DF)
> > 13:06:15.843079 172.16.32.90.2049 > 172.16.17.176.3106736070:
> > reply ok 144
> > setattr [|nfs]
> > 13:06:15.843506 172.16.17.176.3123513286 > 172.16.32.90.2049:
> > 648 write [|nfs]
> > (DF)
> > 13:06:15.843783 172.16.32.90.2049 > 172.16.17.176.3123513286:
> > reply ok 160 write
> > [|nfs]
> > 13:06:15.844069 172.16.17.176.3140290502 > 172.16.32.90.2049:
> > 144 setattr [|nfs]
> > (DF)
> > 13:06:15.844253 172.16.32.90.2049 > 172.16.17.176.3140290502:
> > reply ok 144
> > setattr [|nfs]
> > 13:06:15.844604 172.16.17.176.3157067718 > 172.16.32.90.2049:
> > 648 write [|nfs]
> > (DF)
> >
> > Running as root on the client box doing a bonnie putc()
> > Writing with putc()...         done:  11625 kB/s  70.5 %CPU
> >
> > 13:04:34.530773 172.16.32.90.2049 > 172.16.17.176.2934638278:
> > reply ok 160 write
> > [|nfs]
> > 13:04:34.533983 172.16.17.176.2951415494 > 172.16.32.90.2049:
> > 1472 write [|nfs]
> > (frag 58503:1480@0+)
> > 13:04:34.533995 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@1480+)
> > 13:04:34.533999 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@2960+)
> > 13:04:34.534003 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@4440+)
> > 13:04:34.534007 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@5920+)
> > 13:04:34.534010 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@7400+)
> > 13:04:34.534014 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@8880+)
> > 13:04:34.534018 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@10360+)
> > 13:04:34.534021 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@11840+)
> > 13:04:34.534024 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@13320+)
> > 13:04:34.534028 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@14800+)
> > 13:04:34.534032 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@16280+)
> > 13:04:34.534035 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@17760+)
> > 13:04:34.534039 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@19240+)
> > 13:04:34.534042 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@20720+)
> > 13:04:34.534045 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@22200+)
> > 13:04:34.534049 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@23680+)
> > 13:04:34.534053 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@25160+)
> > 13:04:34.534056 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@26640+)
> > 13:04:34.534060 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@28120+)
> > 13:04:34.534063 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@29600+)
> > 13:04:34.534067 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:1480@31080+)
> > 13:04:34.534070 172.16.17.176 > 172.16.32.90: udp (frag
> > 58503:368@32560)
> > 13:04:34.537357 172.16.32.90.2049 > 172.16.17.176.2951415494:
> > reply ok 160 write
> > [|nfs]
> > 13:04:34.540586 172.16.17.176.2968192710 > 172.16.32.90.2049:
> > 1472 write [|nfs]
> > (frag 58504:1480@0+)
> > 13:04:34.540598 172.16.17.176 > 172.16.32.90: udp (frag
> > 58504:1480@1480+)
> > 13:04:34.540603 172.16.17.176 > 172.16.32.90: udp (frag
> > 58504:1480@2960+)
> >
> >
> > Client nfs v3:
> > null       getattr    setattr    lookup     access     readlink
> > 0       0% 8724    0% 1113998 47% 5225    0% 3084    0% 98      0%
> > read       write      create     mkdir      symlink    mknod
> > 20776   0% 1213403 51% 237     0% 1       0% 3       0% 0       0%
> > remove     rmdir      rename     link       readdir    readdirplus
> > 206     0% 0       0% 95      0% 24      0% 48      0% 416     0%
> > fsstat     fsinfo     pathconf   commit
> > 118     0% 10      0% 0       0% 0       0%
> >
> >
> > -------------------------------------------------------
> > This SF.net email is sponsored by: Perforce Software.
> > Perforce is the Fast Software Configuration Management System offering
> > advanced branching capabilities and atomic changes on 50+ platforms.
> > Free Eval! http://www.perforce.com/perforce/loadprog.html
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
