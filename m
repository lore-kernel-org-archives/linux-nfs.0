From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv2/3 requiring RPC_AUTH_GSS
Date: Fri, 04 Mar 2005 11:03:39 -0800
Message-ID: <1109963019.10173.14.camel@lade.trondhjem.org>
References: <1109890493.4361.95.camel@roadrunner.phys.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7I5Y-0004Ec-KD
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 11:03:52 -0800
Received: from pat2.uio.no
	([129.240.130.19] helo=pat.uio.no ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D7I5W-0007WB-R4
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 11:03:52 -0800
To: Benjamin Bennett <ben@phys.psu.edu>
In-Reply-To: <1109890493.4361.95.camel@roadrunner.phys.psu.edu>
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

to den 03.03.2005 Klokka 17:54 (-0500) skreiv Benjamin Bennett:
>   v4 exports using gss/krb5 work from both FC2 and Solaris 10 clients.
> However, for Solaris 8 I'm using v3 with gss/krb5.
> 
>   The problem I've run into with this, is that in order for the v3
> client to mount (even using gss), it must be given sys/unix access too.
> That pretty much rules out the nice sleep I could have gotten with all
> clients using gss since they could just remount with auth_unix at will.

Could you expand a bit on this? Is the problem that knfsd is failing to
adhere to RFC2623?
The latter says that the NFS server is supposed to accept AUTH_SYS as
being valid for fsinfo(nfsv3) or fsstat+getattr(nfsv2) on the mount
point. Is knfsd doing this?

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
