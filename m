From: David Dougall <davidd@et.byu.edu>
Subject: Re: Question about mounting....
Date: Fri, 31 Jan 2003 10:52:03 -0700 (MST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.50.0301311038440.32750-100000@lewis.et.byu.edu>
References: <013001c2c949$b8a0d9a0$6601a8c0@userl3x55qxqed>
 <shsfzr9xmad.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Heaton <admin@0catch.com>,
        "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from postal2.et.byu.edu ([128.187.122.132])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18efLD-0002gB-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Jan 2003 09:52:39 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsfzr9xmad.fsf@charged.uio.no>
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

Are these stale mounts?  or does it act like the server is still down?  I
use XFS on all of my linux NFS servers and have only had stale mounts
under certain circumstances.  I use the kernel based on 2.4.19rc3 and
nfs-utils-1.0.1.  The problem is how exportfs is called on bootup.  I seem
to recall having the error with other filesystems, so I don't think it is
XFS related.  I had to add an extra "exportfs -r" somewhere in the startup
scripts and all the problems went away.
--David Dougall


On Fri, 31 Jan 2003, Trond Myklebust wrote:

> >>>>> " " == Matt Heaton <admin@0catch.com> writes:
>
>      > mount point is just fine until the server comes back up and
>      > then keeps going (It does this on our servers that use EXT3),
>      > but on our
>
> IIRC XFS loses the value of the fsid when it reboots. In recent
> versions of the nfs-utils + server, you have an /etc/export option to
> set the fsid to a fixed value.
>
> Cheers,
>   Trond
>
>
> -------------------------------------------------------
> This SF.NET email is sponsored by:
> SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
> http://www.vasoftware.com
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>

______________________________________
Inflex Virus Scanner - installed on mailserver for domain @et.byu.edu
Queries to: postmaster@et.byu.edu


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
