From: Benjamin Bennett <ben@phys.psu.edu>
Subject: Re: NFSv2/3 requiring RPC_AUTH_GSS
Date: Sat, 05 Mar 2005 04:47:52 -0500
Message-ID: <1110016071.21281.70.camel@roadrunner.phys.psu.edu>
References: <1109890493.4361.95.camel@roadrunner.phys.psu.edu>
	 <1109963019.10173.14.camel@lade.trondhjem.org>
	 <20050305064537.GD4354@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7VtH-0004OG-ER
	for nfs@lists.sourceforge.net; Sat, 05 Mar 2005 01:48:07 -0800
Received: from faraday.phys.psu.edu ([128.118.49.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D7VtE-0003TP-12
	for nfs@lists.sourceforge.net; Sat, 05 Mar 2005 01:48:06 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050305064537.GD4354@fieldses.org>
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

On Sat, 2005-03-05 at 01:45, J. Bruce Fields wrote:
> On Fri, Mar 04, 2005 at 11:03:39AM -0800, Trond Myklebust wrote:
> > to den 03.03.2005 Klokka 17:54 (-0500) skreiv Benjamin Bennett:
> > >   v4 exports using gss/krb5 work from both FC2 and Solaris 10 clients.
> > > However, for Solaris 8 I'm using v3 with gss/krb5.
> > > 
> > >   The problem I've run into with this, is that in order for the v3
> > > client to mount (even using gss), it must be given sys/unix access too.
> > > That pretty much rules out the nice sleep I could have gotten with all
> > > clients using gss since they could just remount with auth_unix at will.
> > 
> > Could you expand a bit on this? Is the problem that knfsd is failing to
> > adhere to RFC2623?
> > The latter says that the NFS server is supposed to accept AUTH_SYS as
> > being valid for fsinfo(nfsv3) or fsstat+getattr(nfsv2) on the mount
> > point. Is knfsd doing this?
> 
> No.
> 
> The immediate problem, though, is probably just that mountd isn't
> reporting the security flavours correctly.  This shouldn't be too hard
> to fix for someone with the time and inclination.
> 
> (See
> http://www.citi.umich.edu/projects/nfsv4/linux/nfs-utils-patches/1.0.7-1/nfs-utils-1.0.7-06-mountd_flavors.dif
> for a hack that just always returns all the krb5 flavors in the mount
> reply.  All we need to do here is check the export table to figure out
> which to report, and then we'll have a patch worth actually adding to
> nfs-utils.)

I do already have that patch applied (well, the one for 1.0.6).

The problem I saw (can't require gss for v3 access) seems to be the
result of two things:

  A) mountd needs to see the v3 host in exports (or it will return
unknown host). So even though we just want to use gss, we need another
export (auth_unix) to satisfy this.

  I wrote a little code to unconditionally send back a successful mount
response with filehandle and included gss flavors. This led to the
second problem:

  B) knfsd also validates host, so we again need the same auth_unix
export as in A.


  The most simple work-around I could think of was making the auth_unix
export ro, all_squash. But that still allows auth_unix anyone to mount
and be nobody ;-)

  Whether a client is going to use gss for nfs transactions isn't
necessarily known at mount time, so we can't just have mountd ignore
hostnames when gss is going to be used.

  Is there a better way to do this than I did (violating rfc)?  If I can
exclude the root fh from this restriction (allow auth_unix to root fh
only) would it then be rfc ok?


--ben



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
