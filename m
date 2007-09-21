From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS on loopback locks up entire system(2.6.23-rc6)?
Date: Fri, 21 Sep 2007 08:47:27 -0400
Message-ID: <20070921124727.GA15108@fieldses.org>
References: <92cbf19b0709201722k6265e647x31b7d25bc54b63a0@mail.gmail.com>
	<1190335423.6763.180.camel@heimdal.trondhjem.org>
	<92cbf19b0709202012s375c6f54m588987b4bbf552bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-kernel@vger.kernel.org
To: Chakri n <chakriin5@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYhup-0000dm-JV
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 05:47:27 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IYhut-0003yF-Ai
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 05:47:32 -0700
In-Reply-To: <92cbf19b0709202012s375c6f54m588987b4bbf552bc@mail.gmail.com>
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

On Thu, Sep 20, 2007 at 08:12:34PM -0700, Chakri n wrote:
> And unfortunately in my case, I cannot use "mount --bind". I want to
> use the same file system from two different nodes, and I want file &
> record locking to be consistent. The only way to make sure locking is
> consistent is to use loopback NFS on 1 host and NFS mount the same
> file system on other nodes, so that NFS server ensures file & record
> locking to be consistent. Is there any alternative to this?

The NFS server acquires a lock on the exported filesystem before
granting it to an NFS client, so loopback mounting shouldn't add any
extra safety.  If you've witnessed some exception to this rule, please
let us know.

> Is it possible or any efforts to integrate ext3 or other local file
> systems locking & network file system locking, so that user can use
> "mount --bind" on local host and NFS mount on remote nodes, but file &
> record locking will be consistent between both the nodes?

That's the way it works already, more or less.

(It depends a little on what you mean by "file and record locking".  The
byte-range locks acquired by fcntl() have always been enforced over NFS.
Locks acquired by flock() haven't always been, but loopback mounting
doesn't solve this problem.)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
