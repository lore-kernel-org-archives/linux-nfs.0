From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RFC: mount.nfs
Date: Fri, 27 Aug 2004 15:16:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093634193.5758.67.camel@lade.trondhjem.org>
References: <20040827141529.GF23324@suse.de>
	 <1093630421.5758.42.camel@lade.trondhjem.org>
	 <20040827182452.GA20962@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0mDG-0004bH-8u
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 12:16:38 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C0mDF-0002zs-Ou
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 12:16:38 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040827182452.GA20962@suse.de>
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

P=E5 fr , 27/08/2004 klokka 14:24, skreiv Olaf Kirch:

> In what way do these legacy portmappers fail? Does the PMAP_DUMP actually
> kill the portmapper? If we are able to safely identify broken portmappers=
,
> I assume we can fall back to enumerating the available versions by
> sending a GETPORT request with version 0, and loop over that range.
>=20
> I can easily put all that stuff into a library, no problem.

No, it doesn't kill the portmapper, but it returns an error, and so
needs to be dealt with. Putting it in as a fallback case would probably
be fine...

> > the rewrite that is in Fedora Core 2 goes to such lengths to actually
> > "ping" the server.
>=20
> I wasn't aware that Redhat already had a rewrite. I'll take a look.

It's based on some work I did 2 years ago to clean the code up a bit,
and put in support for TCP/UDP probing. It also does things like fix up
"umount" so that we call the correct revision of the mount protocol
(some people like to disable NFSv2 support in mountd for instance)...

> > Also note that ideally, we want to make stuff like this as part of a
> > backend library, then have 3 different programs:
> >   mount.nfs2
> >   mount.nfs3
> >   mount.nfs4
> > that can be called when the user does
> >=20
> >     mount -t nfs -onfsvers=3D%d
>=20
> That's fine with me. But I think we still need a mount.nfs, because
> we need to handle the case where the user doesn't specify an NFS
> version. Calling all mount.nfsX apps in turn may be a bit awkward.

I'm not suggesting that you want to call the mount.nfsX apps in turn,
but I'm thinking that a minimal front end (in "mount" itself for
instance) could do basic probing for version, then call the appropriate
back end (or load it as a library or whatever).
The point is that parsing of the mount options and setting up of the
nfs_mount struct (and any future nfsX_mount structs) and calling down
into the kernel belongs in version-specific modules.

> > The reason why I want to split out nfs2 from the nfs3 mount is that at
> > some point in the near future, I'd like to change the filesystem
> > registration to create 'struct file_system_type' entries for NFSv2 and
> > NFSv3. That will enable us to
> >=20
> >    a) clean up the struct nfs_mount to get rid of all that "struct
> > socket", version 1 legacy crap
>=20
> We can do that now, if we drop the requirement of making the struct
> backward compatible. We already deduce the kernel API version by
> looking at the kernel release number, so that can be done safely.

Sure, and in practice, it boils down to the same thing as you propose as
far as that struct mount is concerned. It's just that you get the extra
benefit that userland can suddenly figure out which versions of NFS the
kernel has been compiled to support.
People do actually still compile NFSv2-only kernels (Linus never misses
an opportinity to yell at me every time I send in some patch that breaks
that 8-)). In the future we also want to be able to give people the
option of NFSv3-only or even NFSv4-only kernels as the older NFS
revisions fade into historical oblivion.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
