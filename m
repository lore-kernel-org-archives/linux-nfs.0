From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Q: How can I run nfs-utils on MIPS uclibc-based distro
	with kernel 2.6?
Date: Wed, 04 Jan 2006 11:58:59 +0100
Message-ID: <1136372340.31785.1.camel@lade.trondhjem.org>
References: <20060104103519.9306.qmail@hoster903.com>
	 <1136371255.28640.26.camel@lade.trondhjem.org>
	 <200601041154.29648.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eu6MS-0008Nm-8h
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 02:59:20 -0800
Received: from pat.uio.no ([129.240.130.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Eu6MR-0002yW-3p
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 02:59:20 -0800
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-Reply-To: <200601041154.29648.vincent.roqueta@ext.bull.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, 2006-01-04 at 11:54 +0100, Vincent Roqueta wrote:
> Le Mercredi 4 Janvier 2006 11:40, Trond Myklebust a =C3=A9crit :
> > On Wed, 2006-01-04 at 10:35 +0000, linux wrote:
> > > According to Vincent Roqueta (I received his  reply to my private
> > > address)   nfs-utils v.1.0.1 shouldn't work with kernels 2.6.
> >
> > ??? Sure it will. 2.6 kernels have legacy support for older versions of
> > both mount and nfs-utils.
> Right ... for NFSv3 only?=20

Yes, for NFSv2 and NFSv3.

NFSv4 needs support from extra daemons and also requires some mountd
changes that are more recent.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
