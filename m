From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 000 of 20] knfsd: Support 'secinfo' exports with
	related cleanups
Date: Wed, 18 Jul 2007 18:57:25 -0400
Message-ID: <11847994502579-git-send-email-bfields@fieldses.org>
References: <20070713114228.3c171a90.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, andros@citi.umich.edu,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBISb-0002vg-Nk
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 15:57:41 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBISf-0007TS-6H
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 15:57:37 -0700
In-Reply-To: <20070713114228.3c171a90.akpm@linux-foundation.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Fri, 13 Jul 2007 11:42:28 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 13 Jul 2007 14:10:25 -0400 "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Fri, Jul 13, 2007 at 12:33:10AM -0700, Andrew Morton wrote:
> > > Please consider feeding knfsd patches through checkpatch in the
> > > future.  It did find several glitches in these patches which you
> > > might have chosen to address.
> >
> > OK.  I guess I'll wait till the next -mm is out, take a look, and
> > address your comments then.
>
> I probably won't get another -mm out until after the 2.6.23 merge window
> closes.  One reason for this is all the extra time which I need to
> devote to code-review, hint.
> 
> But I don't think there was anything which I identified in this nfsd
> batch which needs attention prior to a 2.6.23-rc1 merge.  The checkpatch
> stuff is more a "please do this next time" thing.

OK, so the following address the review comments.

The first two should really be applied before -rc1 if at all possible:

	- the first is a preexisting bug stumbled on while doing this
	  work, also suitable for stable.
	- the second is a fix for a regression introduced by my patches.
	  (Apologies!)

(The other three patches, as you say, can wait till after rc1.)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
