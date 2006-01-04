From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Q: How can I run nfs-utils on MIPS uclibc-based distro with kernel 2.6?
Date: Wed, 4 Jan 2006 11:54:29 +0100
Message-ID: <200601041154.29648.vincent.roqueta@ext.bull.net>
References: <20060104103519.9306.qmail@hoster903.com> <1136371255.28640.26.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eu6FI-0007qD-6K
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 02:51:56 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Eu6FG-00086m-Jg
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 02:51:56 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 8981219D90D
	for <nfs@lists.sourceforge.net>; Wed,  4 Jan 2006 11:51:13 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 09193-07 for <nfs@lists.sourceforge.net>;
 Wed,  4 Jan 2006 11:51:12 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 41FF319D906
	for <nfs@lists.sourceforge.net>; Wed,  4 Jan 2006 11:51:12 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <1136371255.28640.26.camel@lade.trondhjem.org>
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

Le Mercredi 4 Janvier 2006 11:40, Trond Myklebust a =E9crit=A0:
> On Wed, 2006-01-04 at 10:35 +0000, linux wrote:
> > According to Vincent Roqueta (I received his  reply to my private
> > address)   nfs-utils v.1.0.1 shouldn't work with kernels 2.6.
>
> ??? Sure it will. 2.6 kernels have legacy support for older versions of
> both mount and nfs-utils.
Right ... for NFSv3 only?=20
( It I forgot v4 is not yet the standard :/)


Sorry.
Vincent


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
