From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Stale file handle
Date: Tue, 4 Feb 2003 21:09:01 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15935.37181.947378.191993@notabene.cse.unsw.edu.au>
References: <200302031903.53937.chris-nfs@drspirograph.com>
	<200302041218.31527.chris-nfs@drspirograph.com>
	<15935.5764.263002.800295@charged.uio.no>
	<200302041239.22301.chris-nfs@drspirograph.com>
	<shshebk1ldv.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Jensen <chris-nfs@drspirograph.com>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18g011-0004fd-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Feb 2003 02:09:19 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <trond.myklebust@fys.uio.no>) (for <chris-nfs@drspirograph.com>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Tue, 4 Feb 2003 21:09:10 +1100
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on  February 4
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

On  February 4, trond.myklebust@fys.uio.no wrote:
> >>>>> " " == Chris Jensen <chris-nfs@drspirograph.com> writes:
> 
>      > So is it just a coincidence that this has worked for over a
>      > year? I wouldn't have thought so, because there have often been
> 
> You ought to have the source available to you so feel free to take a
> look. However unless you have been using some specially patched
> version of the kernel, then VFAT support will be poor, as described.
> 
> I believe that a lot could be done to fix this particular issue.
> Although it is clear that some compromises will need to be made
> w.r.t. the NFSv3 specs, the stale filehandle thing could perhaps be
> fixed by (for instance) encoding the beginning of the FAT chain of the
> file + the parent directory in the filehandle. Such an encoding is
> admittedly not safe under renames of the file, but it would already be
> a huge improvement.

The filehandles for FAT files have had this information ever since 2.4
first supported FAT (which wasn't the very early 2.4s.  2.2 sort of
supported FAT.. sometimes, maybe).

However the filehandle decoding code doesn't actually use this
information.  It seemed like a lot of work for little gain. I doubt
very much if I will ever bother making it work better.  Ofcourse if
anyone else wants to try ..... :-)

NeilBrown


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


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
