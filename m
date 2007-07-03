From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: unlock when client rejects GRANTED_MSG
Date: Tue, 3 Jul 2007 18:30:33 -0400
Message-ID: <20070703223033.GG14074@fieldses.org>
References: <20070629155226.GA25561@janus> <20070701143801.GA22967@janus>
	<20070701145832.GA17334@fieldses.org>
	<20070701151154.GA23704@janus>
	<20070703205302.GV14074@fieldses.org>
	<20070703222419.GD16497@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5qtF-0004x9-6Y
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 15:30:33 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5qtH-0000sZ-EQ
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 15:30:36 -0700
In-Reply-To: <20070703222419.GD16497@janus>
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

On Wed, Jul 04, 2007 at 12:24:19AM +0200, Frank van Maarseveen wrote:
> I think your patch is addressing something different. It _might_ fix
> the nlm_grant_reply() bug as a side effect

It doesn't fix that on its own, but it might be a starting point.

> but that's already done by the small patch I posted earlier so...

Not completely.  After your patch, for example, a failed attempt to
re-lock a region will result in the originally locked region being
unlocked.

> I think it is best to consider these issues separately.
> 
> But I'm still unsure about who's picking up NLM patches and if server
> or client side matters.

I agree with Trond that this isn't the client's problem.  I think if you
want to pursue this you should try modifying the server to get the
source ip address right.  Post the patch here, and one of us will pick
it up.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
