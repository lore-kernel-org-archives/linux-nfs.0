From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: unlock when client rejects GRANTED_MSG
Date: Tue, 3 Jul 2007 16:43:57 -0400
Message-ID: <20070703204357.GT14074@fieldses.org>
References: <20070629155226.GA25561@janus> <20070701143801.GA22967@janus>
	<20070701145832.GA17334@fieldses.org>
	<20070701151154.GA23704@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5pE6-0001kt-92
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 13:43:58 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5pE7-0007og-ES
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 13:44:01 -0700
In-Reply-To: <20070701151154.GA23704@janus>
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

On Sun, Jul 01, 2007 at 05:11:54PM +0200, Frank van Maarseveen wrote:
> On Sun, Jul 01, 2007 at 10:58:32AM -0400, J. Bruce Fields wrote:
> > But I don't know how much trouble it's worth going to to get this right;
> > the NLM protocol is inherently racy.  Is this something you saw in real
> > life?  What was the client, and why did it refuse the grant?
> 
> The grant was refused because the server replied with the wrong src
> IP address. This bug is easy to trigger, see my earlier posting:
> 
> http://marc.info/?l=linux-nfs&m=118313239503311&q=raw

Is there any reason not to modify the server to get the source address
right?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
