From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsv3 client process stuck in rwsem_down_failed_common()
Date: Mon, 14 May 2007 11:59:45 -0400
Message-ID: <1179158385.6474.11.camel@heimdal.trondhjem.org>
References: <20070514155449.GA5169@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hncxk-0006SP-BK
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 08:59:54 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19YUOVfkqvWSX4zgt57hp9V2LLOa7m62ag=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hncxl-0007of-T3
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 08:59:55 -0700
In-Reply-To: <20070514155449.GA5169@janus>
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

On Mon, 2007-05-14 at 17:54 +0200, Frank van Maarseveen wrote:
> On a 2.6.21.1 NFSv3 client box multiple processes got stuck with
> this trace:
> 
> [<c02926e5>] rwsem_down_failed_common+0x85/0x180
> [<c052a36d>] rwsem_down_read_failed+0x1d/0x30
> [<c052a437>] call_rwsem_down_read_failed+0x7/0x10
> [<c022622e>] nlmclnt_unlock+0x2e/0xc0
> [<c02258da>] nlmclnt_proc+0x29a/0x2d0
> [<c01f088e>] nfs3_proc_lock+0xe/0x10
> [<c01e3904>] do_unlk+0x44/0x70
> [<c01e3a9d>] nfs_lock+0xbd/0x120
> [<c017dfd1>] locks_remove_posix+0xb1/0xc0
> [<c016dc8d>] filp_close+0x2d/0x70
> [<c01248a6>] close_files+0x56/0x70
> [<c012490c>] put_files_struct+0x1c/0x50
> [<c012533a>] do_exit+0x13a/0x3f0
> [<c0125649>] do_group_exit+0x29/0x70
> [<c012e73f>] get_signal_to_deliver+0x21f/0x2b0
> [<c0103e96>] do_signal+0x56/0x160
> [<c0103fde>] do_notify_resume+0x3e/0x40
> [<c01041ae>] work_notifysig+0x13/0x25
> 
> Two processes had an independent shared read lock on different files
> and when killing them with ^C they got stuck in state 'D' with above
> stack trace. I'm not sure what brought then there other than that the
> server went through a number of unusual reboots for testing purposes.

Are there any processes with a name of the form '<hostname>-reclaim'
hanging too?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
