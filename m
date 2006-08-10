From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] fix recursive nlm_file_mutex deadlock
Date: Thu, 10 Aug 2006 11:40:06 -0400
Message-ID: <1155224407.10547.45.camel@localhost>
References: <44DA25D3.3010003@redhat.com>
	<1155159937.15624.22.camel@localhost>  <44DA5CBF.3040309@redhat.com>
	<1155167828.15624.70.camel@localhost>
	<1155223450.3666.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GBCe4-0001M3-CG
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 08:40:28 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GBCe1-00055I-Ck
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 08:40:29 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <1155223450.3666.48.camel@localhost.localdomain>
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

On Thu, 2006-08-10 at 11:24 -0400, Wendy Cheng wrote:

> We simply can't call nlm_release_file() as long as it requires
> nlm_file_mutex (no matter where you move the locking line) within
> nlm_traverse_files() code path. I'm ok with atomic variable though.

As long as we can guarantee that file->f_count doesn't drop to zero (and
we can make that guarantee in nlm_traverse_file()), then the code is
correct.

  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
