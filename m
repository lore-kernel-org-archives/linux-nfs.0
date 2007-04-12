From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Missing handling for NFS4ERR_OLD_STATEID
	in	nfs4_handle_exception?
Date: Thu, 12 Apr 2007 14:07:48 -0400
Message-ID: <1176401268.6664.36.camel@heimdal.trondhjem.org>
References: <1175616589.3531.8.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc3iP-00051p-JS
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 11:08:14 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18o/Y9oxwDYnHderPxU9mRxrciSd2tOFi0=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hc3iL-0000hj-Md
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 11:08:16 -0700
In-Reply-To: <1175616589.3531.8.camel@dyn9047022153>
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

On Tue, 2007-04-03 at 09:09 -0700, Frank Filz wrote:
> I'm looking at the following code, and wondering if something is missing
> in the handling of NFS4ERR_OLD_STATEID. The result is that if this error
> occurs, nfs4_map_errors() will print:
> 
> 	nfs4_map_errors could not handle NFSv4 error 10024

Agreed. We don't really need to worry users with that printk.

> It also looks like the handling of NFS4ERR_DELAY etc. may be wrong,
> since if nfs4_delay() returns without error, it falls through to the
> handling of NFS4ERR_OLD_STATEID.

The correct way to deal with both NFS4ERR_DELAY and NFS4ERR_OLD_STATEID
is simply to retry the request.

As I said in an earlier mail, the NFS4ERR_OLD_STATEID is occurring
because some OPEN/OPEN_DOWNGRADE has caused the stateid to change. All
we can do is retry with the new stateid.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
