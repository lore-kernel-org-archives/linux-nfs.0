From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv2/3 requiring RPC_AUTH_GSS
Date: Sat, 5 Mar 2005 01:45:37 -0500
Message-ID: <20050305064537.GD4354@fieldses.org>
References: <1109890493.4361.95.camel@roadrunner.phys.psu.edu> <1109963019.10173.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Bennett <ben@phys.psu.edu>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7T2O-0004ku-KB
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 22:45:20 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D7T2N-00082b-5B
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 22:45:20 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1109963019.10173.14.camel@lade.trondhjem.org>
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

On Fri, Mar 04, 2005 at 11:03:39AM -0800, Trond Myklebust wrote:
> to den 03.03.2005 Klokka 17:54 (-0500) skreiv Benjamin Bennett:
> >   v4 exports using gss/krb5 work from both FC2 and Solaris 10 clients.
> > However, for Solaris 8 I'm using v3 with gss/krb5.
> > 
> >   The problem I've run into with this, is that in order for the v3
> > client to mount (even using gss), it must be given sys/unix access too.
> > That pretty much rules out the nice sleep I could have gotten with all
> > clients using gss since they could just remount with auth_unix at will.
> 
> Could you expand a bit on this? Is the problem that knfsd is failing to
> adhere to RFC2623?
> The latter says that the NFS server is supposed to accept AUTH_SYS as
> being valid for fsinfo(nfsv3) or fsstat+getattr(nfsv2) on the mount
> point. Is knfsd doing this?

No.

The immediate problem, though, is probably just that mountd isn't
reporting the security flavours correctly.  This shouldn't be too hard
to fix for someone with the time and inclination.

(See
http://www.citi.umich.edu/projects/nfsv4/linux/nfs-utils-patches/1.0.7-1/nfs-utils-1.0.7-06-mountd_flavors.dif
for a hack that just always returns all the krb5 flavors in the mount
reply.  All we need to do here is check the export table to figure out
which to report, and then we'll have a patch worth actually adding to
nfs-utils.)

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
