From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Small optimization for nfs3acl. (was: Re: [PATCH] NFS:
	nfsaclsvc_encode_getaclres() - Fix potential NULL deref and
	tiny optimization.)
Date: Thu, 2 Nov 2006 16:06:36 +0100
Message-ID: <200611021606.36447.agruen@suse.de>
References: <200610272316.47089.jesper.juhl@gmail.com>
	<200610311726.00411.agruen@suse.de>
	<200610312139.23836.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org,
	David Rientjes <rientjes@cs.washington.edu>,
	Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gfe8m-00047k-HJ
	for nfs@lists.sourceforge.net; Thu, 02 Nov 2006 07:06:00 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gfe8j-0002qk-8n
	for nfs@lists.sourceforge.net; Thu, 02 Nov 2006 07:06:01 -0800
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: <200610312139.23836.jesper.juhl@gmail.com>
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

On Tuesday 31 October 2006 21:39, Jesper Juhl wrote:
> Here's a patch for nfs3. Hope it's OK.

It's obviously correct.

Thanks,
Andreas

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
