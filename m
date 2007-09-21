From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS on loopback locks up entire system(2.6.23-rc6)?
Date: Fri, 21 Sep 2007 10:13:25 -0400
Message-ID: <1190384005.6680.20.camel@heimdal.trondhjem.org>
References: <92cbf19b0709201722k6265e647x31b7d25bc54b63a0@mail.gmail.com>
	<1190335423.6763.180.camel@heimdal.trondhjem.org>
	<92cbf19b0709202012s375c6f54m588987b4bbf552bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Chakri n <chakriin5@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYjGQ-0001bK-C3
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 07:13:50 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IYjGV-0005G4-52
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 07:13:55 -0700
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

On Thu, 2007-09-20 at 20:12 -0700, Chakri n wrote:
> Thanks Trond, for clarifying this for me.
> 
> I have seen similar behavior when a remote NFS server is not
> available. Many processes wait end up waiting in nfs_release_page. So,
> what will happen if the remote server is not available,
> nfs_release_page cannot free the memory since it waits on rpc request
> to complete, which never completes and processes wait in there for
> ever?
> 
> And unfortunately in my case, I cannot use "mount --bind". I want to
> use the same file system from two different nodes, and I want file &
> record locking to be consistent. The only way to make sure locking is
> consistent is to use loopback NFS on 1 host and NFS mount the same
> file system on other nodes, so that NFS server ensures file & record
> locking to be consistent. Is there any alternative to this?
> 
> Is it possible or any efforts to integrate ext3 or other local file
> systems locking & network file system locking, so that user can use
> "mount --bind" on local host and NFS mount on remote nodes, but file &
> record locking will be consistent between both the nodes?

Could you be a bit more specific? Is the problem that your application
is using BSD locks (flock()) instead of POSIX locks?

Cheers
   Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
