From: "Sean Hunter" <sean@uncarved.com>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for directories on NFS mounts
Date: Mon, 15 Jul 2002 08:52:21 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020715075221.GC21470@uncarved.com>
References: <E17S18w-0005a7-00@the-village.bc.nu> <Pine.LNX.3.95.1020709154108.14801B-100000@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
  Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net,
  linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from userk185.dsl.pipex.com ([62.188.58.185])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17U0ek-0003lT-00
	for <nfs@lists.sourceforge.net>; Mon, 15 Jul 2002 00:52:31 -0700
To: "Richard B. Johnson" <root@chaos.analogic.com>
In-Reply-To: <Pine.LNX.3.95.1020709154108.14801B-100000@chaos.analogic.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, Jul 09, 2002 at 03:50:17PM -0400, Richard B. Johnson wrote:
> On Tue, 9 Jul 2002, Alan Cox wrote:
> 
> > > That is what it's supposed to do with files. The attached code clearly
> > > shows that it doesn't work with directories. The fsync() instantly
> > > returns, even though there is buffered data still to be written.
> > 
> > Your understanding or code is wrong. Its hard to tell which.
> > 
> > fsync on the directory syncs the directory metadata not the file metadata
> > 
> 
> Well the original complaint was that Linux NFS didn't allow a directory to
> be fsync()ed. I showed that POSIX.4 doesn't provide for fsync()ing
> directories, only files, that you have to fsync() individual files, not
> the directories that contain them. Others said that fsync()ing individual
> files was not necessary, that you only have to fsync() the directory. I
> explained that you have to cheat to even get a fd that can be used
> to fsync() a directory. Then I showed that fsync()ing a directory in this
> manner doesn't work so, we are actually in violent agreement.

I'm not sure whether or not you've got the gist with all the flamage and
shrapnel flying about, however as I understand it, fsync on a directory fd
ensures that all directory ops such as rename()s unlinks(), links() etc are
committed, not that all data pending to all files in that dir are flushed.

To get all changes you need to fsync the dirfd and all the fds of the files as
well.

Because directory changes (such as renames, unlinks etc) are synchronous on NFS
any way, fsync() on a dir fd on an NFS mount can simply return.  There will
never be any outstanding dir ops to flush.  ergo: no bug.

Hope that's clear.

Sean


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
