From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: patch for using >16 groups on 2.6.x client
Date: Tue, 08 Feb 2005 22:53:49 -0500
Message-ID: <1107921229.10994.90.camel@lade.trondhjem.org>
References: <20050208234426.GA27766@janus>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyivZ-0002KN-FE
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 19:54:09 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CyivX-00012j-N0
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 19:54:09 -0800
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20050208234426.GA27766@janus>
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

on den 09.02.2005 Klokka 00:44 (+0100) skreiv Frank van Maarseveen:

> The parts below should be applied in order but after every single patch
> the result will compile and should behave properly (2.6.11-rc3). All
> patches < #30 may be useful anyway as cleanup because they only prepare
> things. Patch 30:
> 
> 	http://www.frankvm.com/nfs-ngroups/2.6.11/30.patch
> 
> is the most interesting one w.r.t. to understanding how it affects the
> structure of the NFS client. See also the README in that directory. This
> is a short description:

I still do not like it. Your methodology is exactly the same as in all
previous iterations of these patches: you are adding code that is very
specific to the AUTH_SYS *RPC* authentication scheme to the *NFS* layer.

I could perhaps accept all this in the mainline kernel, if you could
show me that this code solves a _generic_ problem within RPC
authentication, however so far I have not seen any evidence of this
being the case. The only thing you have claimed it solves is the corner
case of NFS when using > 16 groups and no uid/gid mapping over AUTH_SYS.


We _are_ working to remove the limitations of AUTH_SYS by developing the
new (secure!) authentication schemes based on RPCSEC_GSS principals. In
both of the currently supported mechanisms, the server should be able to
map the context into the full set of uid/gid/groups/... associated with
the principal (with no restrictions).

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
