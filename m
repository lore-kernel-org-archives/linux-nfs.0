From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.4.21-pre] Fix possible SMP race in nfs_sync_page()
Date: Thu, 12 Dec 2002 14:22:01 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15864.36217.293119.33635@charged.uio.no>
References: <15864.25714.339197.675770@charged.uio.no>
	<3DF88C7D.F0398F10@amis.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MTI2-0003z8-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Dec 2002 05:22:10 -0800
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: <3DF88C7D.F0398F10@amis.com>
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

>>>>> " " == Eric Whiting <ewhiting@amis.com> writes:

    >> The following patch fixes a race in nfs_sync_page() whereby one
    >> thread may call the generic sync_page() and then block on a
    >> given page while another thread is working in
    >> mapping->a_ops->readpage().

     > Could this happen on a single processor box under heavy load?

Conceivably, yes, since processes may sleep while in ->readpage().

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
