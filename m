From: Eric Whiting <ewhiting@amis.com>
Subject: Re: [PATCH 2.4.21-pre] Fix possible SMP race in nfs_sync_page()
Date: Thu, 12 Dec 2002 06:17:49 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DF88C7D.F0398F10@amis.com>
References: <15864.25714.339197.675770@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MTDw-00034l-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Dec 2002 05:17:56 -0800
To: trond.myklebust@fys.uio.no
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

Trond Myklebust wrote:
> 
> Hi Marcelo,
> 
>   The following patch fixes a race in nfs_sync_page() whereby one
> thread may call the generic sync_page() and then block on a given page
> while another thread is working in mapping->a_ops->readpage().

Is this a SMP only race? Could this happen on a single processor box
under heavy load?

eric


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
