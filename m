From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 008 of 8] knfsd: nfsd4: don't delegate files that
	have had conflicts
Date: Thu, 21 Jun 2007 12:33:30 -0400
Message-ID: <20070621163330.GE4094@fieldses.org>
References: <20070621142604.727.patches@notabene> <1070621043119.1159@suse.de>
	<20070621162801.GD4094@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	meelap@umich.edu
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1PbA-0002pt-7u
	for nfs@lists.sourceforge.net; Thu, 21 Jun 2007 09:33:32 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1PbC-0000Qr-Di
	for nfs@lists.sourceforge.net; Thu, 21 Jun 2007 09:33:35 -0700
In-Reply-To: <20070621162801.GD4094@fieldses.org>
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

On Thu, Jun 21, 2007 at 12:28:01PM -0400, bfields wrote:
> The authorship information got lost on these last two patches--both were
> originally by Meelap Shah <meelap@umich.edu>.
> 
> (The problem may have been that I had a From: line for him but not a
> Signed-off-by: line?)

Hm, no, actually I think the same happened to patch 1 (from Marc Eshel)
and 4 (from Benny Halevy), neither which had missing signed-off-by's, so
probably your scripts have always ignored From: lines in the body of an
email, and I only just now noticed?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
