From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] 2.4.20 Direct IO patch for NFS. (Note: a trivial API
 change...)
Date: Mon, 30 Sep 2002 12:04:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D98A04C.2FE206EE@digeo.com>
References: <15768.39196.468797.249573@charged.uio.no> <20020930194227.A22095@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Marcelo Tosatti <marcelo@conectiva.com.br>,
        Chuck Lever <cel@netapp.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux FSdevel <linux-fsdevel@vger.kernel.org>,
        NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from packet.digeo.com ([12.110.80.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17w5qM-0000pV-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Sep 2002 12:04:34 -0700
Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id MAA04933
	for <nfs@lists.sourceforge.net>; Mon, 30 Sep 2002 12:04:28 -0700 (PDT)
To: Christoph Hellwig <hch@infradead.org>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Christoph Hellwig wrote:
> 
> On Mon, Sep 30, 2002 at 08:34:04PM +0200, Trond Myklebust wrote:
> >
> > Hi Marcelo,
> >
> >   The following patch implements direct I/O for NFS as a compilation option.
> > It does not in any way touch the standard NFS read/write code, however it
> > does change the interface for generic direct I/O: Instead of taking a
> > 'struct inode' argument, we need to take the full 'struct file' in order
> > to be able to pass the RPC credential information down to the NFS layer.
> 
> I don't think changing the filesystem entry points during 2.4 is an option.
> 

It's a very small change; I wouldn't be very fussed about it personally.

To be source-compatible with out-of-kernel filesystems you could add
a new a_op and do

	if (mapping->direct_IO_which_uses_a_filp)
		use that
	else
		use mapping->direct_IO

but ick.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
