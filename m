From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 2.4.20 Direct IO patch for NFS. (Note: a trivial API change...)
Date: Mon, 30 Sep 2002 20:46:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15768.39971.417077.834216@charged.uio.no>
References: <15768.39196.468797.249573@charged.uio.no>
	<20020930194227.A22095@infradead.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    Marcelo Tosatti <marcelo@conectiva.com.br>,
    Chuck Lever <cel@netapp.com>,
    Linux Kernel <linux-kernel@vger.kernel.org>,
    Linux FSdevel <linux-fsdevel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17w5Za-0002wz-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Sep 2002 11:47:15 -0700
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20020930194227.A22095@infradead.org>
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

>>>>> " " == Christoph Hellwig <hch@infradead.org> writes:

     > I don't think changing the filesystem entry points during 2.4
     > is an option.

DirectIO was added in the middle of the 2.4 'stable' period without
any discussion. It should not benefit from the same protection that
the standard APIs do.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
