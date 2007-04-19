From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Thu, 19 Apr 2007 14:31:19 -0400
Message-ID: <1177007479.6623.14.camel@heimdal.trondhjem.org>
References: <46269362.5040608@amd.com>
	<1176948355.6422.72.camel@heimdal.trondhjem.org>
	<4627B3DD.5050409@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: julia bauer <julia.bauer@amd.com>, nfs@lists.sourceforge.net
To: gregory.baker@amd.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HebPl-0001ga-82
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:31:29 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HebPn-0000Ht-N6
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:31:31 -0700
In-Reply-To: <4627B3DD.5050409@amd.com>
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

On Thu, 2007-04-19 at 13:24 -0500, Gregory Baker wrote:

> Ideas?

Perhaps a limitation on the number of entries in the netgroup on the
server?

Cheers
  Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
