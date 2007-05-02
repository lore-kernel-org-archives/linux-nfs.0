From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] RPC: add wrapper for svc_reserve to account
	for	checksum
Date: Tue, 1 May 2007 20:34:31 -0400
Message-ID: <20070502003431.GK3588@fieldses.org>
References: <20070421131523.GA18100@dantu.rdu.redhat.com>
	<17974.41587.666167.650575@notabene.brown>
	<20070501033310.GB21774@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hj2ni-0001bg-Fr
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 17:34:34 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hj2nj-0002pz-RO
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 17:34:37 -0700
In-Reply-To: <20070501033310.GB21774@fieldses.org>
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

On Mon, Apr 30, 2007 at 11:33:10PM -0400, bfields wrote:
> On Tue, May 01, 2007 at 12:14:11PM +1000, Neil Brown wrote:
> > Bruce:  does it look OK to you?
> 
> It looks sensible, but it's a little late for me--I'll take another look
> at it and run some tests tommorow.

Just to confirm--yep, loks fine.  And I did a quick connectathon run
over krb5i just to make sure.  If someone wants it:

Acked-by: J. Bruce Fields <bfields@citi.umich.edu>

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
