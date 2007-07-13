From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 000 of 20] knfsd: Support 'secinfo' exports with
 related cleanups
Date: Fri, 13 Jul 2007 00:33:10 -0700
Message-ID: <20070713003310.2df90a38.akpm@linux-foundation.org>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J . Bruce Fields" <bfields@puzzle.fieldses.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-kernel@vger.kernel.org, andros@sc8-sf-spam2.sourceforge.net,
	". umich . edu" <andros@citi.umich.edu>, nfs@lists.sourceforge.net,
	Usha Ketineni <uketinen@us.ibm.com>,
	Usha Ketineni <ketineni@us.ibm.com>
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9FeT-0000j5-3H
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 00:33:21 -0700
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9FeW-0001St-Kc
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 00:33:24 -0700
In-Reply-To: <20070710121949.12548.patches@notabene>
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

On Tue, 10 Jul 2007 12:22:37 +1000 NeilBrown <neilb@suse.de> wrote:

> With this patchset it becomes possible to list a number of different
> security flavours that maybe used to access an exported filesystem,
> and to attach different export options (e.g. readonly, rootsquash) to
> different flavours.
> Also, NFSv4 can report which flavours are available on a particular export.

Please consider feeding knfsd patches through checkpatch in the future.  It
did find several glitches in these patches which you might have chosen
to address.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
