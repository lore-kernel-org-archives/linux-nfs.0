From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Wed, 19 Feb 2003 15:39:04 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15955.2664.221481.839408@notabene.cse.unsw.edu.au>
References: <Pine.GSO.4.40.0302171823390.26640-100000@bodoni>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lM1B-0001gF-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 20:39:38 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <nesti@medialab.sissa.it>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 19 Feb 2003 15:39:19 +1100
To: Fabrizio Nesti <nesti@medialab.sissa.it>
In-Reply-To: message from Fabrizio Nesti on Monday February 17
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

On Monday February 17, nesti@medialab.sissa.it wrote:
> Hello to everybody.
> we are reporting a very low performance for nfs access from Solaris clients
> to the linux nfs server on RH8.0. We thought it was udp and upgraded to
> kernel 2.4.20.
> 
> Now the performance is still low, compared to a solaris server:
> 	# time gtar xf /var/tmp/cvs-1.11.5.tar
> 	Writing on Linux_2.4.20> real    0m22.132s
> 	Writing on Solaris_8>    real    0m7.174s
> 
> Both filesystems are mounted with proto=tcp,rsize=32768,wsize=32768.
> Snooping the traffic however, it appears that the linux server is not
> serving with size=32768, but with a maximum size of 8192.
> 
> - Is there a reson for this?

Yes.  Changing a #define in include/linux/nfsd/const.h and recompiling
might work.  There is a small chance that it would cause problems
starting lots of nfsd threads or running with UDP.

> - May this be the reason for the poor performance above?

Unlikely.  It could possibly cause a 10% difference, but not a 300%
difference.

What filesystem are you using on Linux?
ext3 with data=journal and preferably the journal on a separate device
gives quite good performance with  NFS.
Also with ext3, I have found that the no_wdelay export option helps.

NeilBrown

> 
> Thanks in advance,
> Fabrizio Nesti
> 
> 
> PS: Some snoop traffic:
> ...
>   solaris -> linux  NFS C CREATE3 FH=884D (EXCLUSIVE) check_cvs.in
> linux -> solaris    NFS R CREATE3 OK FH=174A
>  solaris -> linux   NFS C SETATTR3 FH=174A
> linux -> solaris    NFS R SETATTR3 OK
>   solaris -> linux  NFS C WRITE3 FH=174A at 0 for 8192 (ASYNC)
>   solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849797604 Len=1460
>   solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849799064 Len=1460
>   solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849800524 Len=1460
>   solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849801984 Len=1460
>   solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849803444 Len=1056
> linux -> solaris    TCP D=793 S=2049 Ack=849804500 Seq=633960980 Len=0
> ...
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
