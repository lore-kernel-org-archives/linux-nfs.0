From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale file handle
Date: 04 Feb 2003 09:49:00 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshebk1ldv.fsf@charged.uio.no>
References: <200302031903.53937.chris-nfs@drspirograph.com>
	<200302041218.31527.chris-nfs@drspirograph.com>
	<15935.5764.263002.800295@charged.uio.no>
	<200302041239.22301.chris-nfs@drspirograph.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fylT-0001Mz-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Feb 2003 00:49:12 -0800
To: Chris Jensen <chris-nfs@drspirograph.com>
In-Reply-To: <200302041239.22301.chris-nfs@drspirograph.com>
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

>>>>> " " == Chris Jensen <chris-nfs@drspirograph.com> writes:

     > So is it just a coincidence that this has worked for over a
     > year? I wouldn't have thought so, because there have often been

You ought to have the source available to you so feel free to take a
look. However unless you have been using some specially patched
version of the kernel, then VFAT support will be poor, as described.

I believe that a lot could be done to fix this particular issue.
Although it is clear that some compromises will need to be made
w.r.t. the NFSv3 specs, the stale filehandle thing could perhaps be
fixed by (for instance) encoding the beginning of the FAT chain of the
file + the parent directory in the filehandle. Such an encoding is
admittedly not safe under renames of the file, but it would already be
a huge improvement.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
