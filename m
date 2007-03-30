From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/18] export operations rewrite
Date: Fri, 30 Mar 2007 13:34:53 +1000
Message-ID: <17932.34141.590792.120454@notabene.brown>
References: <20070317010946.GA24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HX7tI-0003ky-Tc
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 20:35:05 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HX7tJ-0007Vz-Ve
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 20:35:07 -0700
In-Reply-To: message from Christoph Hellwig on Saturday March 17
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

On Saturday March 17, hch@infradead.org wrote:

less that 2 weeks later....

> This patchset is a medium scale rewrite of the export operations
> interface.  The goal is to make the interface less complex, and
> easier to understand from the filesystem side, aswell as preparing
> generic support for exporting of 64bit inode numbers.
> 
> This touches all nfs exporting filesystems, and I've done testing
> on all of the filesystems I have here locally (xfs, ext2, ext3, reiserfs,
> jfs)

My only question involves motivation.

  You say "less complex", but to me it just looks "different" - though
  being very familiar with the original, that might be a biased view.
  Can you say more about how it is less complex?
  Maybe the extension to generic 64bit support will make that clear...

  But then generic 64bit support should just be an independent set of
  helper functions that can be plugged in to the export_operations
  structure.

For what it does, the code looks fine, and I can see some definite
improvements here and there, but I'm not clear on the over-all
motivation.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
