From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: [Fwd: Re: NFS-HOWTO]
Date: Wed, 20 Mar 2002 00:06:58 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020320000658.I27743@vestdata.no>
References: <1016561902.2031.23.camel@vaio> <shsn0x4mm2h.fsf@charged.uio.no> <shsit7smkjj.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Tavis Barr <tb62@columbia.edu>, nfs@lists.sourceforge.net
Received: from stine.vestdata.no ([195.204.68.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nShD-0007KJ-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 15:07:11 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsit7smkjj.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Tue, Mar 19, 2002 at 08:20:32PM +0100
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, Mar 19, 2002 at 08:20:32PM +0100, Trond Myklebust wrote:
>    - Changes to the individual filesystems so that they can save and
>      retrieve the extra 96 bits (=3D=3D 32 bits * (mtime + atime + ctim=
e))
>      as part of the on-disk metadata.
>      This is non-trivial, since a lot of these filesystems have not
>      got much padding left in their inodes (particularly once acls
>      etc. have grabbed their share of real-estate). Even finding 32
>      free bits is a real problem for ext[23]...

I think Ted was talking about doing a disk-format change for ext[23]
soon (to improve resizing support and to extend fields like timestamps
and link-counters).

For reiserfs adding more data in the on-disk metadata is perhaps less of
a problem than for other filesystems, because reiserfs can handle
multiple inode-types on the same filesystem. (Of course old kernels
would not work with the new format, so it's still not trivial).

I haven't checked xfs, jfs or any of the other filesystems.

> One solution might be to only keep the full 64-bit data in the VFS
> inode cache, and to zero the low 32-bits whenever we have to reload
> the metadata from the disk.
> That means that each time the file falls out of cache, then the mtime
> would appear to change on the client (which might then proceed to
> invalidate its data cache). Not entirely satisfactory, but probably
> better than nothing...

Filesystems that _do_ have support for 64-bit data on-disk could still
take advantage, right?=20


--=20
Ragnar Kj=F8rstad
Big Storage

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
