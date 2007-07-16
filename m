From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: build problems with latest nfs-utils
Date: Sun, 15 Jul 2007 21:31:19 -0400
Message-ID: <20070716013119.GA14612@fieldses.org>
References: <469AB4D6.20902@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAFQr-0000RU-3y
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 18:31:38 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAFQt-0000Ee-GT
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 18:31:28 -0700
In-Reply-To: <469AB4D6.20902@oracle.com>
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

On Sun, Jul 15, 2007 at 07:59:18PM -0400, Chuck Lever wrote:
> I updated my git repo to the latest version of nfs-utils, and now I can no 
> longer build nfs-utils.  I use
>
> ./configure --disable-gss --disable-nfsv4
>
> and get these compilation errors:

Whoops, yes, I didn't think to test my changes with gss or nfsv4
disabled.  I'll take a look at this tomorrow; thanks for noticing that.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
