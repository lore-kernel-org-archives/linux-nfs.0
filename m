From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Fri, 25 Oct 2002 23:46:34 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021025234634.A26957@redhat.com>
References: <15797.63730.223181.75888@notabene.cse.unsw.edu.au> <20021025.185234.08315285.taka@valinux.co.jp> <15801.15328.866301.720864@notabene.cse.unsw.edu.au> <20021026.121150.74753877.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 185HuH-0005W2-00
	for <nfs@lists.sourceforge.net>; Fri, 25 Oct 2002 20:46:38 -0700
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20021026.121150.74753877.taka@valinux.co.jp>; from taka@valinux.co.jp on Sat, Oct 26, 2002 at 12:11:50PM +0900
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Sat, Oct 26, 2002 at 12:11:50PM +0900, Hirokazu Takahashi wrote:
> OK.
> 
> It's goot that you're implementing vfs_readv and vfs_writev which
> I've also realized it doesn't support aio yet.

The aio methods are soon switching over to vectored operations for a 
few reasons.  It's likely that non-vectored methods will be gone soon.

		-ben
-- 
"Do you seek knowledge in time travel?"


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
