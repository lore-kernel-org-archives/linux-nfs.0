From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [GIT] NFS client updates for 2.6.22...
Date: Thu, 03 May 2007 21:14:51 +0200
Message-ID: <1178219691.24217.20.camel@twins>
References: <1178117571.5435.10.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjglX-00056o-5V
	for nfs@lists.sourceforge.net; Thu, 03 May 2007 12:14:59 -0700
Received: from amsfep19-int.chello.nl ([62.179.120.14])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HjglZ-0006As-4Z
	for nfs@lists.sourceforge.net; Thu, 03 May 2007 12:15:01 -0700
In-Reply-To: <1178117571.5435.10.camel@heimdal.trondhjem.org>
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

On Wed, 2007-05-02 at 07:52 -0700, Trond Myklebust wrote:
> Hi Linus,
> 
> Please pull from the repository at
> 
>    git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

I can confirm that this solves my missing IO completions problem; or at
least, my test has been running for 8h+ and still going strong, whereas
previous I would be lucky to get 1h.

Would it be reasonable to include the relevant patches in a
later .21-stable release?


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
