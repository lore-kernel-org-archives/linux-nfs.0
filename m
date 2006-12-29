From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS has caching?
Date: Fri, 29 Dec 2006 11:51:21 +0100
Message-ID: <1167389481.6106.54.camel@lade.trondhjem.org>
References: <b66ddc900612281822n3df54e44se296b937b58d158@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H0FKr-0006qq-FC
	for nfs@lists.sourceforge.net; Fri, 29 Dec 2006 02:51:37 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19CovoAjOx/hLq1i6/OhOt9t2OxdOn6nQM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H0FKr-0000sF-Pn
	for nfs@lists.sourceforge.net; Fri, 29 Dec 2006 02:51:39 -0800
To: howard chen <howachen@gmail.com>
In-Reply-To: <b66ddc900612281822n3df54e44se296b937b58d158@mail.gmail.com>
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

On Fri, 2006-12-29 at 10:22 +0800, howard chen wrote:
> I have around 100 files, currently NFS shared among 5 servers, all
> servers access the file quite frequently, e.g. 10 hits per second per
> server.
> 
> I cannot afford to rync since i want the delay of write as small as
> possible, e.g. less than 1 second.
> 
> 
> I want to know, since the file will be accessed quite frequent, does
> NFS has build-in caching functions that if files are not modified, it
> will not try to fetch from the network?

Short answer: yes.

Long answer: http://nfs.sourceforge.net/#faq_a8

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
