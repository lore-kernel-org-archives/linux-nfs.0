From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Desynchronized ncommit
Date: Thu, 19 Apr 2007 14:29:02 -0400
Message-ID: <1177007342.6623.11.camel@heimdal.trondhjem.org>
References: <4627B39A.9070604@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HebNR-0001SS-OW
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:29:23 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19YwMvFB8TkMSgKf/ZI+9FVwyli83qyQUM=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HebNS-0005Om-VO
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:29:08 -0700
In-Reply-To: <4627B39A.9070604@oracle.com>
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

On Thu, 2007-04-19 at 14:23 -0400, Chuck Lever wrote:
> I've noticed this message in my system log over the past few days:
> 
> Apr 17 10:14:04 schiele kernel: NFS: desynchronized value of nfs_i.ncommit.
> 
> It looks like it started appearing when the following patch was applied 
> to 2.6.21-rc.  Any suggestions on what I can do to debug this further?

Please apply patches 1 - 5 from
http://client.linux-nfs.org/Linux-2.6.x/2.6.21-rc7/
and check that they work for you too.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
