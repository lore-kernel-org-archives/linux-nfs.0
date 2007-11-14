From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Use of delayed request information in nlmsvc_lookup_host
Date: Wed, 14 Nov 2007 14:50:57 -0500
Message-ID: <1195069857.7584.58.camel@heimdal.trondhjem.org>
References: <473B3D0B.3060204@oracle.com>
	<1195065798.7584.37.camel@heimdal.trondhjem.org>
	<473B45C9.4060708@oracle.com>
	<1195069262.7584.54.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsOGH-0002LC-Eh
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 11:50:57 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsOGM-00007F-R4
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 11:51:03 -0800
In-Reply-To: <1195069262.7584.54.camel@heimdal.trondhjem.org>
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


On Wed, 2007-11-14 at 14:41 -0500, Trond Myklebust wrote:
> On Wed, 2007-11-14 at 14:00 -0500, Chuck Lever wrote:
> > That's correct.  I'm just trying to understand why, historically, 
> > rq_daddr was just the 32-bit address and not a full sockaddr to begin 
> > with.  There may be something we're missing, like "we didn't want to add 
> > another large field to this structure due to memory alignment or 
> > allocation efficiency concerns".  :-)
> 
> Actually, rq_daddr by definition pretty much has to be of the same
> address family as rq_addr, since they are the two endpoints for the same
> socket. 
> 
> However I can't see where rq_addr is being initialised for UDP sockets.
> That is sort of worrying given that it is used among other things by the
> nfsd duplicate reply cache...

Gah. Never mind... The wretched thing is wrapped by a useful svc_addr()
'helper' that returns its address.

Problem solved, then. Use the sa_family from rq_addr in order to figure
out how to interpret rq_daddr.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
