From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: possible client stale filehandle bug?
Date: Thu, 24 Feb 2005 11:33:43 -0800
Message-ID: <1109273623.11433.52.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130853976D@lavender-fe.eng.netapp.com>
	 <4213B9C2.2040709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Charles Lever <Charles.Lever@netapp.com>,
	Garrick Staples <garrick@usc.edu>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4Okg-0004Qv-9W
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 11:34:22 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D4OkK-0000rB-RV
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 11:34:22 -0800
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <4213B9C2.2040709@redhat.com>
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

on den 16.02.2005 Klokka 16:23 (-0500) skreiv Neil Horman:
> I agree, it probably doesn't re-drive on any operation that doesn't walk 
> a path, which is in line with what RHEL is doing currently.  I didn't 
> mean to imply that solaris retired ESTALE in all occurances of the 
> event.  Anywho, Can you point me to your patches?  I'd be interested to 
> know how you managed to implement retry on ESTALE without leaking into 
> the VFS, which I think you will recall was the big sticking point that 
> we were debating here.

It does leak into the VFS, but in a way that is non-intrusive. The VFS
basically sets a new flag, LOOKUP_REVAL, in the struct nameidata flags
(which are passed down to d_op->d_revalidate() on Linux 2.4.x).
The NFS code takes that as an command to expire the caches, and force a
revalidation.

The exact same trick is performed on Linux-2.6.x: see the patch
"linux-2.6.11-31-stale_retry.dif"  in
     http://client.linux-nfs.org/Linux-2.6.x/2.6.11-rc5/

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
