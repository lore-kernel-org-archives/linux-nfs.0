From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SUNRPC: Fix
	xdr_decode_string_inplace()	mixed	sign comparison
Date: Thu, 01 Nov 2007 11:45:37 -0400
Message-ID: <1193931937.7590.1.camel@heimdal.trondhjem.org>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
	<1193857219.7454.70.camel@heimdal.trondhjem.org>
	<7D9707A4-3260-4ADA-9235-8DF945EA2EF9@oracle.com>
	<1193889489.7511.17.camel@heimdal.trondhjem.org>
	<4729F2A2.4030505@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IncDj-0000tY-LN
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 08:44:35 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IncDn-0004xc-QU
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 08:44:41 -0700
In-Reply-To: <4729F2A2.4030505@oracle.com>
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


On Thu, 2007-11-01 at 11:37 -0400, Chuck Lever wrote:
> >> -xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
> >> +xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, unsigned int maxlen)
> >>  {
> >>  	unsigned int	len;
>  >
> > Nope. maxlen should be of the same type as *lenp.
> > 
> > Trond
> 
> Thus I now argue that both *lenp and maxlen should either be unsigned 
> integers or size_t.  Negative string lengths make no sense whatsoever.
> 
> If we change both arguments, then we should also change the callers, at 
> least to be consistent.

That would be fine by me.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
