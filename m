From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Disabling the client cache using file locks
Date: Mon, 23 May 2005 11:13:36 -0400
Message-ID: <1116861216.10814.24.camel@lade.trondhjem.org>
References: <9E621559095AA746B22B21CD4FAF99A50FA5C8@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DaEdA-0005nx-DQ
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 08:14:12 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DaEd7-0006nJ-IV
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 08:14:12 -0700
To: Edward Hibbert <Edward.Hibbert@dataconnection.com>
In-Reply-To: <9E621559095AA746B22B21CD4FAF99A50FA5C8@EDINMAIL1.ad.datcon.co.uk>
Sender: nfs-admin@lists.sourceforge.net
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

m=C3=A5 den 23.05.2005 Klokka 15:43 (+0100) skreiv Edward Hibbert:
> So I'm looking for ways of reducing the number of locks.
> Possibilities:=20
> - Make a patch to the kernel (or NFS utils?) to _entirely_ disable
> client-side caching of file contents over NFS.  I have dedicated boxes
> which have no requirement to do client-side caching at all so this is
> a serious option.  Any code pointers?

Why doesn't the existing O_DIRECT support suffice for your purposes?

> - Use nolock to prevent the locks hitting the NFS server - but I think
> that would still hit lockd/statd on the client?=20
> - Not to bother with the locks round the writes, but use fsync
> instead.  Do folk think that would work?

That depends entirely on _why_ you are using locking. Is it to ensure
that two processes don't overwrite the same byte range, or is it to
ensure that writes are flushed to disk?

If the latter, then O_SYNC or O_DIRECT will suffice.

If the former, then locking is your only option, and you will be stuck
with your current performance numbers.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
