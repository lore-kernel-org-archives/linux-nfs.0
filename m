From: trond.myklebust@fys.uio.no
Subject: Re: Force client page cache invalidation?
Date: Thu, 26 Feb 2004 13:35:15 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <32886.207.214.87.84.1077798915.squirrel@webmail.uio.no>
References: <403B9842.9070001@ibl.bm>
    <1145.130.128.48.179.1077653208.squirrel@webmail.uio.no>
    <20040226085718.GB1197@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "ralph gonzalez" <rgonzale@ibl.bm>,nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwKlP-0007Tr-KS
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 04:37:15 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwKVp-0007kV-V1
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 04:21:10 -0800
To: "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20040226085718.GB1197@suse.de>
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

På to , 26/02/2004 klokka 00:57, skreiv Olaf Kirch:
> > Linux does not support this sort of kludge and is unlikely to do so
for
> > the near future. The VM simply cannot support it.
>
> What about using fadvise(POSIX_FADV_DONTNEED) - shouldn't this
> do the trick? Or does it refuse to invalidate mapped pages?

fadvise(POSIX_FADV_DONTNEED) uses the same interface that NFS does to
invalidate pages (invalidate_mapping_pages()), so it has the same
weaknesses: if you have unmapped those pages since whenever it was NFS
tried to invalidate them, then it will work, but there is no way for the
user to guarantee that it will.
Moreover, fadvise() is only available under Linux 2.6.x...

I did, however, see an encouraging posting by Daniel Phillips on the
linux-kernel list yesterday, which indicates he is working on this
problem. See the thread about "Distributed mmap API".

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
