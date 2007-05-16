From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: exportfs bug
Date: Wed, 16 May 2007 12:13:52 -0400
Message-ID: <20070516161352.GB9895@fieldses.org>
References: <20070516153438.GA30140@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoM8R-0005J3-HE
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 09:13:55 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HoM8R-0008MG-VF
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 09:13:58 -0700
In-Reply-To: <20070516153438.GA30140@janus>
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

On Wed, May 16, 2007 at 05:34:38PM +0200, Frank van Maarseveen wrote:
> Multiple exportfs commands within a second don't work as expected. This
> is caused by writing either the wall clock time or the /etc/exports mtime
> to various /proc files, all with the granularity of 1 second. Scripts
> can easily issue more than one exportfs command within that time.
> 
> A repeated sequence of
> 
> - script modifies /etc/exports
> - script runs exportfs -r
> 
> fails horribly (client gets EACCES, ESTALE)
> 
> IMO exportfs should at least hide the time granularity problem e.g. by
> maintaining a timestamp file, waiting if necessary.

This is a known problem, and should be fixed in the latest nfs-utils:

	http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=commitdiff;h=fd9097110f74f39bce89ec3a341fd9b686a68719;hp=89fb5a45d2020aaee203dd9016d98c3ff9d9f991

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
