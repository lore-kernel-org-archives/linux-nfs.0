From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 926917: make knfsd interact cleanly with HSMs
Date: Thu, 31 Mar 2005 11:39:52 +1000
Message-ID: <1112233192.1991.1031.camel@hole.melbourne.sgi.com>
References: <20050315074949.GA4541@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DGog9-0000tR-JF
	for nfs@lists.sourceforge.net; Wed, 30 Mar 2005 17:41:01 -0800
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DGofs-0004LU-UJ
	for nfs@lists.sourceforge.net; Wed, 30 Mar 2005 17:41:01 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <20050315074949.GA4541@sgi.com>
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

On Tue, 2005-03-15 at 18:49, Greg Banks wrote:
> This patch seeks to remedy the interaction between knfsd and HSMs by
> providing mechanisms to allow knfsd to tell an underlying filesystem
> (which supports HSMs) not to block for reads, writes and truncates
> of offline files.  It's a port of a Linux 2.4 patch used in SGI's
> ProPack distro for the last 12 months.  The patch:

Any news on this patch?  Is it good, bad, ugly, or what?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
