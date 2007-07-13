From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 000 of 20] knfsd: Support 'secinfo' exports
	with	related cleanups
Date: Fri, 13 Jul 2007 14:10:25 -0400
Message-ID: <20070713181025.GM12582@fieldses.org>
References: <20070710121949.12548.patches@notabene>
	<20070713003310.2df90a38.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J . Bruce Fields" <bfields@puzzle.fieldses.org>,
	NeilBrown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	"andros @ citi . umich . edu" <andros@citi.umich.edu>,
	nfs@lists.sourceforge.net, Usha Ketineni <uketinen@us.ibm.com>,
	Usha Ketineni <ketineni@us.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9Pb2-0003QV-RA
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 11:10:28 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9Pb5-0006Sg-7C
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 11:10:32 -0700
In-Reply-To: <20070713003310.2df90a38.akpm@linux-foundation.org>
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

On Fri, Jul 13, 2007 at 12:33:10AM -0700, Andrew Morton wrote:
> On Tue, 10 Jul 2007 12:22:37 +1000 NeilBrown <neilb@suse.de> wrote:
> 
> > With this patchset it becomes possible to list a number of different
> > security flavours that maybe used to access an exported filesystem,
> > and to attach different export options (e.g. readonly, rootsquash) to
> > different flavours.
> > Also, NFSv4 can report which flavours are available on a particular export.
> 
> Please consider feeding knfsd patches through checkpatch in the future.  It
> did find several glitches in these patches which you might have chosen
> to address.

OK.  I guess I'll wait till the next -mm is out, take a look, and
address your comments then.  Thanks.--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
