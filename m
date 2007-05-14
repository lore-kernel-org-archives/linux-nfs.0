From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsv3 client process stuck in rwsem_down_failed_common()
Date: Mon, 14 May 2007 12:56:03 -0400
Message-ID: <1179161763.6474.31.camel@heimdal.trondhjem.org>
References: <20070514155449.GA5169@janus>
	<1179158385.6474.11.camel@heimdal.trondhjem.org>
	<20070514160547.GB5169@janus>
	<1179159094.6474.21.camel@heimdal.trondhjem.org>
	<20070514161512.GC5169@janus>
	<1179160379.6474.25.camel@heimdal.trondhjem.org>
	<20070514163919.GA6063@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HndqK-0003oa-8P
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 09:56:24 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18EgV+4PIrLh7NBrxlzrbMNHKuSALpqmrg=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HndqM-0001P9-LG
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 09:56:19 -0700
In-Reply-To: <20070514163919.GA6063@janus>
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

On Mon, 2007-05-14 at 18:39 +0200, Frank van Maarseveen wrote:
> On Mon, May 14, 2007 at 12:32:59PM -0400, Trond Myklebust wrote:
> > On Mon, 2007-05-14 at 18:15 +0200, Frank van Maarseveen wrote:
> > > > Could you please use 'echo 0 >/proc/sys/sunrpc/rpc_debug' in order to
> > > > find out on which rpc queue these tasks are sleeping?
> > > 
> > > -pid- proc flgs status -client- -prog- --rqstp- -timeout -rpcwait -action- ---ops--
> > > 30871 0002 0480      0 c7708614 100021 f43f4000 10000000 xprt_pending c050e4d0 c057f3f4
> > > 30873 0002 0480      0 f00b4eb4 100021 cc809000 10000000 xprt_pending c050e4d0 c057f3f4
> >                                                   ^^^^^^^^ Ouch!
> > 
> > That is a pretty massive timeout. What is your value
> > of /proc/sys/fs/nfs/nlm_timeout ?
> 
> Unfortunately it became necessary to reboot the machine :-(. Right now it says 10.

10 seconds looks like the correct default. I assume that you hadn't
changed that value prior to the reboot...

One last question, just in case: what value are you using for CONFIG_HZ?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
