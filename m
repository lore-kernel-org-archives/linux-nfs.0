From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale file handle
Date: Tue, 4 Feb 2003 02:25:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15935.5764.263002.800295@charged.uio.no>
References: <200302031903.53937.chris-nfs@drspirograph.com>
	<200302041044.45333.chris-nfs@drspirograph.com>
	<shsznpcopqe.fsf@charged.uio.no>
	<200302041218.31527.chris-nfs@drspirograph.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18frq8-0004ML-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 17:25:32 -0800
To: Chris Jensen <chris-nfs@drspirograph.com>
In-Reply-To: <200302041218.31527.chris-nfs@drspirograph.com>
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

    >> What type of filesystem are you using on the server?
     > Ohy, yes that :) FAT32 (vfat module)

Ouch. You are out of luck.

Unfortunately FAT filesystems are not very NFS-friendly as they lack a
reliable way to generate an NFS filehandle. (The NFS filehandle is a
way of uniquely identifying the file to the server in a manner that
does not depend on the pathname).

The current implementation in knfsd relies heavily on the file staying
in the server's 'dentry cache' until the NFS client has finished with
it. If/when memory pressure forces garbage collection on the dcache,
the server will lose its mapping between file and NFS filehandle, and
you will get a 'stale file handle' error being returned to the client.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
