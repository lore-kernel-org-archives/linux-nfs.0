From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Rename window
Date: Fri, 11 Nov 2005 08:41:12 -0500
Message-ID: <1131716472.8805.19.camel@lade.trondhjem.org>
References: <9E621559095AA746B22B21CD4FAF99A557356D@EDINMAIL1.ad.datcon.co.uk>
	 <20051111133036.GA3847@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Edward Hibbert <Edward.Hibbert@dataconnection.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EaZ9w-0003Xm-LT
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 05:41:40 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EaZ9w-0004B8-7b
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 05:41:40 -0800
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20051111133036.GA3847@hmsendeavour.rdu.redhat.com>
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

On Fri, 2005-11-11 at 08:30 -0500, Neil Horman wrote:

> I don't believe rename ever guaranteed atomicity of its operation.  If you want
> to guarantee atomicity I expect you will want to implement a locking strategy
> around the directories/files you are modifying in the rename operation using fcntl
> locking.

No. Edward is correct in that a POSIX filesystem is supposed to
guarantee atomicity (this is one reason why we have a dedicated rename()
instead of playing games like link(a,b); unlink(b);).

Unfortunately, as I said, there are issues in the VFS...

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
