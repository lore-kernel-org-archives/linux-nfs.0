From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] statfs fails with EOVERFLOW
Date: Tue, 23 Mar 2004 11:25:46 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080059146.3109.19.camel@lade.trondhjem.org>
References: <20040323130513.GB30984@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5oip-0008Cz-Uh
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 08:25:47 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B5oip-0008Gd-OD
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 08:25:47 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040323130513.GB30984@suse.de>
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

P=E5 ty , 23/03/2004 klokka 08:05, skreiv Olaf Kirch:

> So the proper fix IMO is for the client to perform an fstat call select
> the proper bsize based on the tbytes value. This can be done either in
> user space or in the kernel.

This will tend to fail if you are using strong authentication on NFSv3.
The only NFSv3 call you can rely upon to succeed at mount time is
fsinfo().

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
