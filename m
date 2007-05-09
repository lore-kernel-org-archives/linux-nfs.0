From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS server patches to support RDMA
Date: Wed, 9 May 2007 14:45:58 -0400
Message-ID: <20070509184558.GG23778@fieldses.org>
References: <1178735209.9563.32.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlrAp-00007w-Ht
	for nfs@lists.sourceforge.net; Wed, 09 May 2007 11:46:03 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HlrAq-0003nZ-VD
	for nfs@lists.sourceforge.net; Wed, 09 May 2007 11:46:06 -0700
In-Reply-To: <1178735209.9563.32.camel@trinity.ogc.int>
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

On Wed, May 09, 2007 at 01:26:49PM -0500, Tom Tucker wrote:
> I have a large set of patches that supports encoding RPC messages on an
> RDMA transport in the NFS server. The patches include changes to the
> existing SVC infrastructure as well as quite a bit of code in new files.
> 
> What is the best way to present these patches for review?

Unless there are just tons and tons of them, the best thing would
probably be just to send them here, one patch to a message....

> We had thought that we could stage this in a git repository on
> linux-nfs.org. 

... but it could be helpful to have that as well.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
