From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Wed, 23 Oct 2002 17:23:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15798.48861.50331.47443@charged.uio.no>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
	<20021018.221103.35656279.taka@valinux.co.jp>
	<15797.63730.223181.75888@notabene.cse.unsw.edu.au>
	<20021023.125304.28780747.taka@valinux.co.jp>
	<15798.15709.589542.122490@notabene.cse.unsw.edu.au>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hirokazu Takahashi <taka@valinux.co.jp>,
    nfs@lists.sourceforge.net,
    "William A.(Andy) Adamson" <andros@citi.umich.edu>,
    trond.myklebust@fys.uio.no
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184NM1-0006A5-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 08:23:30 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15798.15709.589542.122490@notabene.cse.unsw.edu.au>
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

>>>>> " " == Neil Brown <neilb@cse.unsw.edu.au> writes:

     > Hmm. I wonder what plans there are for this w.r.t. to NFSv4
     > client.  Andy? Trond?

There's really no need for anything beyond what we have. There's no
call in the client for stringing more than one set of pages together:
you are always dealing with a single set of contiguous pages to
read/write.

     > I suspect that COMPOUNDS with multiple READ or WRITE requests
     > would be fairly rare, and it would probably be reasonable to
     > respond with ERESOURCE (or however it is spelt).

Alternatively, you could add a list_head to the xdr_buf struct so that
you can string several of them together. Frankly, though, it would be
a rather strange NFSv4 client that wants to do this sort of
operation. There's just no advantage to it...

     > I was thinking it would be nice to be able to do the
     > udp-checksum at the same time as the copy-into-page-cache, but
     > maybe we just say that you need a NIC that does checksums if
     > you want to do single-copy NFS writes.

Right. The very last thing you want to do is to copy into the page
cache, then find out that the checksum didn't match up.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
