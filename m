From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 10:42:40 -0500
Message-ID: <20070307154240.GB26553@fieldses.org>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: Simon Peter <simon.peter@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOyHJ-0000zU-JT
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 07:42:09 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOyHH-0008CG-GI
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 07:42:11 -0800
In-Reply-To: <20070307160633.77afb618.simon.peter@gmx.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Mar 07, 2007 at 04:06:33PM +0100, Simon Peter wrote:
> just verified that the server indeed spins up all disks before
> answering the request. I thus suspect it is somehow checking all exports
> whenever any one export is mounted. Is this correct behaviour?

Hm.  If you have the nfs-utils source, you can see there's a loop in

	nfs-utils/utils/mountd/cache.c:nfsd_fh()

that stats the root of each export, in two places; the first it looks
like you shouldn't hit if you don't have the mountpoint export option
set:

	 if (exp->m_export.e_mountpoint &&
	     !is_mountpoint(exp->m_export.e_mountpoint[0]?
	                    exp->m_export.e_mountpoint:
	                    exp->m_export.e_path))
		dev_missing ++;

The second is to figure out which filesystem the filehandle that you passed in
that getattr is for:

         if (stat(exp->m_export.e_path, &stb) != 0)
                 continue;
         if (fsidtype == 1 &&
             ((exp->m_export.e_flags & NFSEXP_FSID) == 0 ||
              exp->m_export.e_fsid != fsidnum))
                 continue;
         if (fsidtype != 1) {
                 if (stb.st_ino != inode)
                         continue;
                 if (major != major(stb.st_dev) ||
                     minor != minor(stb.st_dev))
                         continue;
         }
	/* It's a match !! */

You could stick a printf() in there somewhere or something to check whether
this is really where it's waiting.

Could we cache the stat information in the export and then double-check it if
necessary when there's a match?  Or is there some way we could get the kernel
to keep that cached for us?

It seems reasonable to want to export filesystems from a bunch of disks without
necessarily keeping them all spun up all the time.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
