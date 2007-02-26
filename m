From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: asynchronous locks for cluster exports
Date: Mon, 26 Feb 2007 14:52:32 -0500
Message-ID: <20070226195232.GC6412@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLltU-0004oH-Bq
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 11:52:20 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HLltU-0000gd-4L
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 11:52:22 -0800
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

On Sat, Feb 03, 2007 at 12:30:55AM -0500, J. Bruce Fields wrote:
> 
> This is another attempt at a posix locking interface that allows us to
> provide NFS clients with cluster-coherent locking without blocking lockd
> while the filesystem goes off and talks to other nodes.

Marc and I have an updated version of this at:

	git://linux-nfs.org/~bfields/linux.git

(See the server-cluster-locking-api branch.)

Changes include:

	- bugfixes for GFS2; thanks to some setup help from Wendy Chang
	  and others, Marc has been able to run locking tests against an
	  nfs-exported GFS2 filesystem
	- preallocation of storage for conflicting lock in lockd's
	  testlock implementation, to avoid a race identified by Trond
	- Cleanup suggested by Christoph and others, including:
		- creation of posix-to-flock helper functions
		- rewrite of posix_test_lock interface to agree with
		  ->lock( ,F_GETLK, )
		- removal of some unnecessary parentheses, untangling of
		  some slightly tortured logic

We're hoping to get a detailed review from Trond sometime in the coming
month, after which we'll probably mailbomb linux-fsdevel again, but
any comments are welcome in the meantime.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
