From: trond.myklebust@fys.uio.no
Subject: Re: NFS sync write performance
Date: Tue, 24 Feb 2004 23:21:51 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1769.130.128.48.179.1077661311.squirrel@webmail.uio.no>
References: <01e201c3faf8$a0d67af0$9002a8c0@consensys.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avkx5-0003ws-L4
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 14:22:55 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avkjm-0003ja-38
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 14:09:10 -0800
To: "Alex Wun" <alexwun@consensys.com>
In-Reply-To: <01e201c3faf8$a0d67af0$9002a8c0@consensys.com>
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

På ty , 24/02/2004 klokka 09:07, skreiv Alex Wun:
> As a side note, after modifying some code in the nfs client, nfs server,
and xfs filesystem, I was able to
> get performance up to ~45MB/s on the 7-disk Raid5 and ~60MB/s on a
7-disk Raid0.  These customizations
> are still very primitive but they might be worth looking into.  I know
the nfs developers are busy, but would
> they be interested in providing some feedback?

Mind explaining what you did to tweak the client/server? If most of the
change was due to setting the "async" export option, then the above
increase would be expected (as is the accompanying reduction in server
failure survival rate).

Cheers,
 Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
