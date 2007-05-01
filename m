From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] RPC: add wrapper for svc_reserve to account
	for	checksum
Date: Mon, 30 Apr 2007 23:33:10 -0400
Message-ID: <20070501033310.GB21774@fieldses.org>
References: <20070421131523.GA18100@dantu.rdu.redhat.com>
	<17974.41587.666167.650575@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hij74-00058I-36
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 20:33:14 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hij75-0003R0-Fm
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 20:33:16 -0700
In-Reply-To: <17974.41587.666167.650575@notabene.brown>
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

On Tue, May 01, 2007 at 12:14:11PM +1000, Neil Brown wrote:
> I don't think this BUG_ON is correct.  If a readdir finds zero entries,
> then will be some trailer information in the 'tail', but page_len will
> be 0.  I think the following patch is correct and could fix that.

Yep.

> Bruce:  does it look OK to you?

It looks sensible, but it's a little late for me--I'll take another look
at it and run some tests tommorow.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
