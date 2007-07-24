From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Status of mount.nfs
Date: Tue, 24 Jul 2007 17:10:49 -0400
Message-ID: <1185311449.6586.69.camel@localhost>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>
	<20070716092047.GA10353@uio.no>
	<18075.17719.855332.259470@notabene.brown>
	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com> <20070724172451.GA14026@uio.no>
	<46A6652F.8000707@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDRej-0005Ft-Vc
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 14:10:58 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+Xoakoz9NtH03CnXJyFNwKzHfJfsFGgBE=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDRen-0004XB-4h
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 14:11:01 -0700
In-Reply-To: <46A6652F.8000707@oracle.com>
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

On Tue, 2007-07-24 at 16:46 -0400, Chuck Lever wrote:

> The TCP case fails because mount.nfs is using the portmapper even though 
> the user has specified the ports on the command line.  Could that be the 
> root cause of the failure?

If the user specifies a port, then there is no real good reason to use
the portmapper:

      * For the case of the mount protocol, we should just try an RPC
        call and then look at the returned RPC error values to figure
        out which versions of the protocol are supported if it fails (or
        alternatively, fall back to UDP if the TCP connection fails).
      * If the mount call has succeeded and we have a port for the NFS
        server, we should probably just try the mount call for a
        sufficiently recent kernel, then look at the returned error
        codes. For older kernels (pre 2.6.13?) which don't return decent
        error values, then ping first in userland and look at the RPC
        return values. Retry with UDP if TCP doesn't work...

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
