From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFSv4 and client caching to local disk?
Date: Mon, 31 Mar 2003 13:50:52 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55481@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "James Pearson" <james-p@moving-picture.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1907BD-0002NM-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 13:50:59 -0800
To: "Jake Gold" <jake@dtiserv2.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> I am also extremely interested in something like this.

caching large files on local disk is one of the few
reasonable uses for a disk-based NFS client cache.

> I think the Zeus web server's model for in-memory caching=20
> would be great for NFS clients doing disk caching.
>=20
> Something like this would be great:
>=20
> cache_directory =3D /cache
> 	Directory where cache files are stored
> cache_files
> 	Size of the web server file cache (number of files)
> cache_small_file
> 	Maximum size of a 'small' file (bytes) (system page size)
> cache_large_file
> 	Minimum size of a 'large' file (bytes)
> cache_stat_expire
> 	Time for which the response of a stat() call is cached (seconds)

the NFS protocol specifies certain rules for when attribute
cache entries expire, so this kind of control over your client's
cache isn't possible without breaking the NFS protocol.

> cache_max_bytes
> 	Maximum size to reserve for cached files (bytes) (0 =3D no limit)
> cache_flush_interval
> 	Time after which unaccessed files are flushed from the=20
> cache (seconds)
> cache_cooling_time Integer
> 	any file modified in the last 'n' seconds is not cached
> cache_max_filename_length Integer
> 	filenames greater than this length aren't cached (Zero=20
> is no limit)=20


> I have a FAS940 with a cluster of Linux machines mounting=20
> _read-only_ volumes over NFSv3.
> My situation is the same as James Pearson's....those machines=20
> read large, rarely modified files, where memory caching=20
> doesn't help a whole lot. It would be very nice to be able to=20
> have my under-worked local disks take some of the load off the filer.

have you determined why the filer is "overworked?"  which
version of NFS client do you use?  which protocol (TCP/UDP)?
if UDP, have you looked for signs of IP fragmentation?

the best thing you can do for now is make sure the bandwidth
between your filer and clients is at its maximum.

> Are there currently _any_ client-side NFS caching solutions=20
> (even something that requires some extra work)?
>=20
> Thanks in advance,
> Jake
>=20
> On Mon, 31 Mar 2003 13:33:39 +0100
> James Pearson <james-p@moving-picture.com> wrote:
>=20
> > "Lever, Charles" wrote:
> > >=20
> > > hi james-
> > >=20
> > > > I'm trying to find out more about 'cachefs' type file systems
> > > > that can
> > > > cache NFS data to a client's local disk - I've come across a
> > > > couple of
> > > > references that seem to indicate that this may be=20
> possible with NFSv4.
> > > >
> > > > Does (will?) the Linux NFSv4 client support this feature?
> > >=20
> > > Sun implemented cachefs on Solaris for earlier versions of NFS.
> > > it really has nothing to do with which version of NFS that is
> > > in use.
> >=20
> > I've briefly looked at this on IRIX clients some time ago -=20
> but we don't
> > have many IRIX boxes in use now.
> > =20
> > > there is sporadic interest in a cachefs on Linux, and i know of
> > > at least one generic prototype.  a specific implementation of
> > > client-side disk caching that is available today is contained
> > > in the Linux OpenAFS client (known as the AFS cache manager).
> >=20
> > I have done some limited searching of the net for info and=20
> come across a
> > few attempts with earlier kernels - and I am aware of some the
> > issues/problems associated with doing this.
> > =20
> > > cachefs becomes rather more interesting when used in conjunction
> > > with NFSv4 file delegations -- that makes NFS behave in a fashion
> > > similar to AFS client-side disk caching with callbacks.
> >=20
> > My hopes were raised as the NFSv4 specs suggest that low=20
> level support
> > for client disk caches is available - rather than being a=20
> 'bolt-on' for
> > earlier versions - hence my question.
> > =20
> > > there currently is no explicit plan to implement cachefs by the
> > > team that is working on NFSv4 for Linux.  a disk cache has
> > > rather limited usefulness compared to a memory cache.  what is
> > > your application for it?
> >=20
> > Mainly for reading large files that don't change (much) - i.e.
> > effectively in a read-only mode. The total size of the=20
> required files is
> > greater than the clients memory size - in fact any disk=20
> caching of NFS
> > data doesn't necessarily need to survive a reboot of the client, so
> > caching NFS file system data to swap could be enough for my=20
> needs ...
> >=20
> > James Pearson
> >=20
> >=20
> > -------------------------------------------------------
> > This SF.net email is sponsored by: ValueWeb:=20
> > Dedicated Hosting for just $79/mo with 500 GB of bandwidth!=20
> > No other company gives more support or power for your=20
> dedicated server
> > http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >=20
>=20


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
