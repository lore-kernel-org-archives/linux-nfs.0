From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Kernel NFS nfs_update_inode Oops in 2.6.20.11
Date: Wed, 27 Jun 2007 21:26:26 -0400
Message-ID: <1182993986.5311.82.camel@heimdal.trondhjem.org>
References: <20070623153345.GA22117@ligo.caltech.edu>
	<1182615064.5859.2.camel@heimdal.trondhjem.org>
	<20070623215131.GC27551@ligo.caltech.edu>
	<20070627230453.GA14474@ligo.caltech.edu>
	<1182986558.5311.70.camel@heimdal.trondhjem.org>
	<20070627232616.GG9806@ligo.caltech.edu> <4683073A.7080006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stuart Anderson <anderson@ligo.caltech.edu>,
	nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3imF-0003cw-2I
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 18:26:32 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+YC/qCqD7osd/cbJo5xhL7WGY9kqjEdOk=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3imH-0004uD-P9
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 18:26:34 -0700
In-Reply-To: <4683073A.7080006@oracle.com>
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

On Wed, 2007-06-27 at 20:56 -0400, Chuck Lever wrote:
> Stuart Anderson wrote:
> > On Wed, Jun 27, 2007 at 07:22:38PM -0400, Trond Myklebust wrote:
> >> On Wed, 2007-06-27 at 16:04 -0700, Stuart Anderson wrote:
> >>> This has patch has now been stable for 5 days on two different machines.
> >>>
> >>> Any thoughts about the "bad sequence-id error"?
> >> I seem to remember that a couple of sources of state corruption were
> >> found in the server in and around the 2.6.20 series. Do I remember
> >> correctly, Bruce?
> > 
> > In this case Solaris is the server and Linux 2.6.20.14 is the client.
> 
> Just a "me too" -- I see loads of these messages on a static NFSv4 home 
> directory mount point to Solaris Nevada b63.  Clients are 2.6.21 and above.

tcpdump please

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
