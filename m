From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: RFC: nlmclnt_grant() address check vs. callback address
	binding
Date: Tue, 3 Jul 2007 16:33:43 -0400
Message-ID: <20070703203343.GS14074@fieldses.org>
References: <20070702154918.GA543@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5p4B-0000gy-BA
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 13:33:43 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5p4D-0006FR-NN
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 13:33:46 -0700
In-Reply-To: <20070702154918.GA543@janus>
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

On Mon, Jul 02, 2007 at 05:49:18PM +0200, Frank van Maarseveen wrote:
> At first I thought fixing the server is the right thing to do because
> the server behavior is arguably incorrect. Not easy but certainly doable
> (I'd do it if it has a chance of being accepted).

Makes sense to me.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
