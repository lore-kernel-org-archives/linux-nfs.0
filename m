From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale file handle
Date: Tue, 4 Feb 2003 11:40:40 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15935.39080.407774.146836@charged.uio.no>
References: <200302031903.53937.chris-nfs@drspirograph.com>
	<200302041218.31527.chris-nfs@drspirograph.com>
	<15935.5764.263002.800295@charged.uio.no>
	<200302041239.22301.chris-nfs@drspirograph.com>
	<shshebk1ldv.fsf@charged.uio.no>
	<15935.37181.947378.191993@notabene.cse.unsw.edu.au>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Jensen <chris-nfs@drspirograph.com>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18g0Vk-00010g-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Feb 2003 02:41:04 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>, Gordon Chaffee <chaffee@cs.berkeley.edu>
In-Reply-To: <15935.37181.947378.191993@notabene.cse.unsw.edu.au>
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

>>>>> " " == Neil Brown <neilb@cse.unsw.edu.au> writes:

    >> I believe that a lot could be done to fix this particular
    >> issue.  Although it is clear that some compromises will need to
    >> be made w.r.t. the NFSv3 specs, the stale filehandle thing
    >> could perhaps be fixed by (for instance) encoding the beginning
    >> of the FAT chain of the file + the parent directory in the
    >> filehandle. Such an encoding is admittedly not safe under
    >> renames of the file, but it would already be a huge
    >> improvement.

     > The filehandles for FAT files have had this information ever
     > since 2.4 first supported FAT (which wasn't the very early
     > 2.4s.  2.2 sort of supported FAT.. sometimes, maybe).

     > However the filehandle decoding code doesn't actually use this
     > information.  It seemed like a lot of work for little gain. I
     > doubt very much if I will ever bother making it work better.
     > Ofcourse if anyone else wants to try ..... :-)


The VFAT filesystem is listed as being maintained by Gordon
Chaffee. If this is still the case, perhaps he could be persuaded to
give it a try?
If not, then it sounds like a golden opportunity for someone who would
like an extra entry on their CV ;-)

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
