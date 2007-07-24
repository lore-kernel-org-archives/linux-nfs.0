From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Status of mount.nfs
Date: Tue, 24 Jul 2007 13:50:05 -0400
Message-ID: <1185299405.6586.25.camel@localhost>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>
	<20070716092047.GA10353@uio.no>
	<18075.17719.855332.259470@notabene.brown>
	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com>  <20070724172451.GA14026@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDOWT-0007mN-LE
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 10:50:14 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/hAOEhXUs38iaBG+T4lkIjwMkeqs75N8I=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDOWW-0004Uf-3S
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 10:50:17 -0700
In-Reply-To: <20070724172451.GA14026@uio.no>
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

On Tue, 2007-07-24 at 19:24 +0200, Steinar H. Gunderson wrote:
> On Mon, Jul 23, 2007 at 06:13:42PM -0400, Chuck Lever wrote:
> > It would help if we could take a look at a clean network trace of the bad 
> > and the good mount operations.
> 
> It was quite simple to test this myself. I started the kernel server on a
> machine, then shut down portmap. First I did:
> 
>   fugl:~> sudo mount -t nfs -o port=2049,mountport=901,nfsvers=3 192.168.0.101:/ /mnt
>   mount: mount to NFS server '192.168.0.101' failed: System Error: Connection refused.
> 
> The dump is attached as "default.dump". Then I did
> 
>   fugl:~> sudo mount -t nfs -o port=2049,mountport=901,nfsvers=3,udp 192.168.0.101:/ /mnt 
> 
> which is attached as "udp.dump".
> 
> Note that in default.dump, UDP is simply never tried at all. I believe that
> to be a bug.

Nope. Nowhere in the documentation will you find a promise to fall back
to UDP.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
