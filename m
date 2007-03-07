From: Simon Peter <simon.peter@gmx.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 19:44:18 +0100
Message-ID: <20070307194418.97fee0ec.simon.peter@gmx.de>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP17m-0006qI-UE
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:44:31 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HP17m-00050b-KP
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:44:33 -0800
In-Reply-To: <20070307154240.GB26553@fieldses.org>
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

> > just verified that the server indeed spins up all disks before
> > answering the request. I thus suspect it is somehow checking all
> > exports whenever any one export is accessed. Is this correct
> > behaviour?
> Hm.  If you have the nfs-utils source, you can see there's a loop in
> 	nfs-utils/utils/mountd/cache.c:nfsd_fh()
> that stats the root of each export, in two places; the first it looks
> like you shouldn't hit if you don't have the mountpoint export option
> set:

Correct. This one is never hit in my case.

> The second is to figure out which filesystem the filehandle that you
> passed in that getattr is for:
>          if (stat(exp->m_export.e_path, &stb) != 0)
>                  continue;

This is where the wait for the respective disk to spin up occurs.

> Could we cache the stat information in the export and then
> double-check it if necessary when there's a match?  Or is there some
> way we could get the kernel to keep that cached for us?

I could certainly cook up a patch for mountd to cache that information
on its own. I don't have too much clue about how the kernel does its
cacheing, though. If it's useful to do that directly in mountd, I could
get my hands on it.

> It seems reasonable to want to export filesystems from a bunch of
> disks without necessarily keeping them all spun up all the time.

This is at least what I would like to see...

Thanks,
Simon

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
