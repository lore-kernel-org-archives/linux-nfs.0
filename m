From: "Derek Labian" <derek@ioerror.com>
Subject: RE: High Performance NFS
Date: Thu, 31 Oct 2002 16:08:03 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <012801c28129$fca6b060$1400005b@ipservices1.ioerror.com>
References: <3DC19893.626B5DF5@amis.com>
Reply-To: <derek@ioerror.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [66.250.32.135] (helo=mail1.la.ioerror.com)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 187NTi-0007sY-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 14:07:50 -0800
To: <eric_whiting@amis.com>
In-Reply-To: <3DC19893.626B5DF5@amis.com>
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

FreeBSD on the clients and servers.

NFS Version 3.

"How fast is your writes without considering the network. Make sure your
disks are as fast as possible before throwing NFS/network into the
picutre."

Were not doing any writes, just reads.  I'm sure its not a network
congestion
issue though, all gigabit and the switch has a 17.5Gbps backplane.

The disks are 36G 10k RPM.  The only step would be 15k RPM but thats an
expensive
swap.

"How fast is your gigE for ftp transfers? gigE isn't automatically
125Mbytes/s -- you have to set it up right.

Then test NFS. Is your 12-13MB/s read or writes?"

I can copy files at 15MBps no problem when the loads are lite.  But thats
a sequential read of a single file.  When there are 5000 files being
accessed its not so pretty.  :)

There are pretty much no write's in this configuration.

Derek Labian
 Faulk Enterprises, http://www.faulkent.com
 Gnutelliums, http://www.gnutelliums.com
 PH/FX: 281-447-6449 CELL: 713-502-0410
 ADDR: 505 North Belt #355, Houston, Tx 77060
 MAIL ADDR: PO BOX 11726 Spring, Tx 77373


-----Original Message-----
From: eric_whiting@amis.com [mailto:eric_whiting@amis.com]
Sent: Thursday, October 31, 2002 2:55 PM
To: derek@ioerror.com
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] High Performance NFS


What is the linux version of the server? Clients? NFSv3 or NFSv2? This
is a somewhat important question. NFS has improved a lot over the last
12 months.

I suggest something like this:

1. benchmark local storage.
How fast is your writes without considering the network. Make sure your
disks are as fast as possible before throwing NFS/network into the
picutre.

2. benchmark network.
How fast is your gigE for ftp transfers? gigE isn't automatically
125Mbytes/s -- you have to set it up right.

Then test NFS. Is your 12-13MB/s read or writes?

Derek Labian wrote:
>
> I'm really looking for a high performance NFS solution
> and determining the bottlenecks is key for this upgrade.
>
> We currently have 2 Dedicated NFS servers.  Supermicro
> boxes w/ Dual P3 1Ghz, 1GB RAM and an adaptec 2100s w/
> 128MB cache connected to Dell u160 powervaults.
>
> All the servers are connected through gigabit ethernet.
>
> It seems we really start peaking out the disks at about
> 12-13MB a sec.  This seems kind of slow, but the accesses
> are not sequential because of the volume.  The drives
> are 10k RPM btw.
>
> The servers run FreeBSD (latest) and distribute files to
> 8 other servers.  The average file size is around 5MB
> but peaks up to several hundred MB's depending on whats
> happening on any given day.
>
> Also, when peak traffic occurs, the NFS processes all
> get stuck in disk access, and the requests start queing
> up.
>
> For this reason, we have modified the NFSD and NFS Header
> file thats part of the Kernel to support much  more then
> 20 Daemons.
>
> This help performance dramatically.
>
> Additionally, we have tried different levels of read ahead
> blocks, block sizes etc.  Read aheads above 1 work fine
> until the load peaks up.  (Since its reading more data)
>
> Also, smaller then 8k blocks seem to slow it down and
> larger then 8k blocks seem to slow it down.
>
> Hence we use 8k blocks, 1 read ahead block, UDP.
>
> So, is there any suggestings for getting more performance
> out of these things, or if we simply need to upgrade further
> what are the suggestions for high performance NFS at a
> reasonable cost.
>
> Derek
>
> -------------------------------------------------------
> This sf.net email is sponsored by: Influence the future
> of Java(TM) technology. Join the Java Community
> Process(SM) (JCP(SM)) program now.
> http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
