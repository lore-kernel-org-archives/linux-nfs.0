From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: 2.4.20 TCP server + solaris client performance
Date: Tue, 18 Feb 2003 09:35:26 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D552F8@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Alan Powell <lakerfaniam2@yahoo.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lBej-0004HB-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 09:35:45 -0800
Received: from frejya.corp.netapp.com (frejya [10.10.20.91])
	by mx01.netapp.com (8.12.6/8.12.6/NTAP-1.4) with ESMTP id h1IHZdeZ012372
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 09:35:39 -0800 (PST)
Received: from black.eng.netapp.com (black.eng.netapp.com [10.56.10.24])
	by frejya.corp.netapp.com (8.12.6/8.12.6/NTAP-1.4) with ESMTP id h1IHZcM4014893
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 09:35:38 -0800 (PST)
To: Fabrizio Nesti <nesti@medialab.sissa.it>
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

> 8192 block size is a Linux daemon limitation.

i think what alan meant is that the Linux NFS server
cannot respond to read or write requests larger than
8KB, although that will change soon (or already has).
the Linux NFS client supports rsize and wsize up to
32KB.

> Also,
> don't switch to TCP unless you need to. UDP will be
> faster if you have a decent network. Revert back to
> UDP, and on the client side, run "nfsstat -c" and
> monitor the number of retransmissions. If that number
> doesn't increase, you have a clean network, and you
> should stay on UDP.

TCP is a better default in the long run for the following
reasons:

1.  many networks (even switched LANs) contain parts
    that run at different speeds (GbE vs. 100Mb/s).
    TCP is better at managing flow control in situations
    like this, or in the infrequent cases where a network
    congestion storm occurs.

2.  UDP is exposed to some rare forms of silent data
    corruption resulting from the IP ID field wrapping.

3.  the performance overhead of TCP will shrink over time
    so that there is no longer much advantage to using
    UDP.

4.  as time goes on, NFS over TCP will work well enough
    in every network scenario, whereas UDP will always be
    limited (UDP will probably never work well on WANs,
    for example).

also note that future versions of NFS will not support UDP
at all, so it is best to start getting comfortable with
stream protocols now.

the real overhead of using TCP is probably not visible for
a server with disks so slow that it can't fill its local
network pipe.

> --- Fabrizio Nesti <nesti@medialab.sissa.it> wrote:
> > Hello to everybody.
> > we are reporting a very low performance for nfs
> > access from Solaris clients
> > to the linux nfs server on RH8.0. We thought it was
> > udp and upgraded to
> > kernel 2.4.20.
> > 
> > Now the performance is still low, compared to a
> > solaris server:
> > 	# time gtar xf /var/tmp/cvs-1.11.5.tar
> > 	Writing on Linux_2.4.20> real    0m22.132s
> > 	Writing on Solaris_8>    real    0m7.174s
> > 
> > Both filesystems are mounted with proto=tcp,rsize=32768,wsize=32768.
> > Snooping the traffic however, it appears that the
> > linux server is not
> > serving with size=32768, but with a maximum size of
> > 8192.
> > 
> > - Is there a reson for this?
> > - May this be the reason for the poor performance
> > above?
> > 
> > Thanks in advance,
> > Fabrizio Nesti
> > 
> > 
> > PS: Some snoop traffic:
> > ...
> >   solaris -> linux  NFS C CREATE3 FH=884D
> > (EXCLUSIVE) check_cvs.in
> > linux -> solaris    NFS R CREATE3 OK FH=174A
> >  solaris -> linux   NFS C SETATTR3 FH=174A
> > linux -> solaris    NFS R SETATTR3 OK
> >   solaris -> linux  NFS C WRITE3 FH=174A at 0 for
> > 8192 (ASYNC)
> >   solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849797604 
> > Len=1460
> >   solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849799064 
> > Len=1460
> >   solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849800524 
> > Len=1460
> >   solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849801984 
> > Len=1460
> >   solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849803444 
> > Len=1056
> > linux -> solaris    TCP D=793 S=2049 Ack=849804500
> > Seq=633960980 Len=0
> > ...
> > 
> > 
> > 
> >
> -------------------------------------------------------
> > This sf.net email is sponsored by:ThinkGeek
> > Welcome to geek heaven.
> > http://thinkgeek.com/sf 
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net 
> > https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 
> __________________________________________________
> Do you Yahoo!?
> Yahoo! Shopping - Send Flowers for Valentine's Day 
http://shopping.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf _______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
