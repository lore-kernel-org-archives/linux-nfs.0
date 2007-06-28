From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv4 uninitialized mtime
Date: Thu, 28 Jun 2007 09:32:12 -0400
Message-ID: <20070628133212.GA26588@fieldses.org>
References: <1182987805.5311.77.camel@heimdal.trondhjem.org>
	<20070628004904.GK9806@ligo.caltech.edu>
	<20070628005957.GA16461@ligo.caltech.edu>
	<20070627211559.e9fc68dd.jlayton@redhat.com>
	<20070628025327.GA18337@ligo.caltech.edu>
	<7FEBE408-60C8-41F3-99A3-9ABF1A381D44@sun.com>
	<20070628032356.GB18337@ligo.caltech.edu>
	<CACFA76B-43D8-454C-B06A-AAA4EF38A033@Sun.COM>
	<20070628034455.GD18337@ligo.caltech.edu>
	<2DD93BC2-E5C2-45C5-A054-D0580004E3AC@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stuart Anderson <anderson@ligo.caltech.edu>,
	nfs@lists.sourceforge.net
To: Spencer Shepler <Spencer.Shepler@Sun.COM>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3u6Y-0008PM-Q6
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 06:32:15 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3u6a-00050j-VL
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 06:32:18 -0700
In-Reply-To: <2DD93BC2-E5C2-45C5-A054-D0580004E3AC@Sun.COM>
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

On Wed, Jun 27, 2007 at 10:59:10PM -0500, Spencer Shepler wrote:
> The Solaris NFSv3 server will, upon "get acl", map the underlying
> ZFS ACL format to the NFSv3/ACL format.  However, on setting of
> an acl, an error is returned (NOSUP).  The decision was made that
> because of the imperfect mapping on acl set in this path that
> an error would be returned.

Mapping back from an NFSv3 to an NFSv4 ACL should be pretty easy,
shouldn't it?  Especially if it's an ACL that was just fetched from
the server--so it shouldn't be particularly exotic.

> I believe the Solaris client would map the ENOTSUP back to the
> application as is and that may help the application adapt
> its behavior (avoid erroring out if that isn't desired).

But, yes, maybe cp could be smarter.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
