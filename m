From: Alan Powell <lakerfaniam2@yahoo.com>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Mon, 17 Feb 2003 18:36:11 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030218023611.28056.qmail@web12203.mail.yahoo.com>
References: <Pine.GSO.4.40.0302171823390.26640-100000@bodoni>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web12203.mail.yahoo.com ([216.136.173.87])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18kxcB-00087w-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 18:36:11 -0800
To: Fabrizio Nesti <nesti@medialab.sissa.it>, nfs@lists.sourceforge.net
In-Reply-To: <Pine.GSO.4.40.0302171823390.26640-100000@bodoni>
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

8192 block size is a Linux daemon limitation. Also,
don't switch to TCP unless you need to. UDP will be
faster if you have a decent network. Revert back to
UDP, and on the client side, run "nfsstat -c" and
monitor the number of retransmissions. If that number
doesn't increase, you have a clean network, and you
should stay on UDP.


--- Fabrizio Nesti <nesti@medialab.sissa.it> wrote:
> Hello to everybody.
> we are reporting a very low performance for nfs
> access from Solaris clients
> to the linux nfs server on RH8.0. We thought it was
> udp and upgraded to
> kernel 2.4.20.
> 
> Now the performance is still low, compared to a
> solaris server:
> 	# time gtar xf /var/tmp/cvs-1.11.5.tar
> 	Writing on Linux_2.4.20> real    0m22.132s
> 	Writing on Solaris_8>    real    0m7.174s
> 
> Both filesystems are mounted with
> proto=tcp,rsize=32768,wsize=32768.
> Snooping the traffic however, it appears that the
> linux server is not
> serving with size=32768, but with a maximum size of
> 8192.
> 
> - Is there a reson for this?
> - May this be the reason for the poor performance
> above?
> 
> Thanks in advance,
> Fabrizio Nesti
> 
> 
> PS: Some snoop traffic:
> ...
>   solaris -> linux  NFS C CREATE3 FH=884D
> (EXCLUSIVE) check_cvs.in
> linux -> solaris    NFS R CREATE3 OK FH=174A
>  solaris -> linux   NFS C SETATTR3 FH=174A
> linux -> solaris    NFS R SETATTR3 OK
>   solaris -> linux  NFS C WRITE3 FH=174A at 0 for
> 8192 (ASYNC)
>   solaris -> linux  TCP D=2049 S=793 Ack=633960980
> Seq=849797604 Len=1460
>   solaris -> linux  TCP D=2049 S=793 Ack=633960980
> Seq=849799064 Len=1460
>   solaris -> linux  TCP D=2049 S=793 Ack=633960980
> Seq=849800524 Len=1460
>   solaris -> linux  TCP D=2049 S=793 Ack=633960980
> Seq=849801984 Len=1460
>   solaris -> linux  TCP D=2049 S=793 Ack=633960980
> Seq=849803444 Len=1056
> linux -> solaris    TCP D=793 S=2049 Ack=849804500
> Seq=633960980 Len=0
> ...
> 
> 
> 
>
-------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


__________________________________________________
Do you Yahoo!?
Yahoo! Shopping - Send Flowers for Valentine's Day
http://shopping.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
