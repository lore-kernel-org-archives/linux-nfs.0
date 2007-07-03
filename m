From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: BUG: unable to handle kernel paging request at virtual
	address 6b6b6b6f
Date: Tue, 3 Jul 2007 15:39:37 -0400
Message-ID: <20070703193937.GM14074@fieldses.org>
References: <20070703071735.GA9481@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5oDr-0003J0-3s
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 12:39:39 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5oDt-0003FE-Cp
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 12:39:42 -0700
In-Reply-To: <20070703071735.GA9481@janus>
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

On Tue, Jul 03, 2007 at 09:17:35AM +0200, Frank van Maarseveen wrote:
> I've reported this earlier but now I figured out how to reproduce it:
> start nfsd with 50 instances and then try to stop it.

So, all it takes is this?:

	rpc.nfsd 50
	rpc.nfsd 0

> 
> Jul  3 09:10:39 kernel: BUG: unable to handle kernel paging request at virtual address 6b6b6b6f
> Jul  3 09:10:39 kernel:  printing eip:
> Jul  3 09:10:39 kernel: c053f594
> Jul  3 09:10:39 kernel: *pde = 00000000
> Jul  3 09:10:39 kernel: Oops: 0000 [#1]
> Jul  3 09:10:39 kernel: SMP
> Jul  3 09:10:39 kernel: Modules linked in: vmthrottle

What's vmthrottle, by the way?

> Jul  3 09:10:39 kernel: CPU:    1
> Jul  3 09:10:39 kernel: EIP:    0060:[<c053f594>]    Not tainted VLI
> Jul  3 09:10:39 kernel: EFLAGS: 00010202   (2.6.21.5-x160 #1)
> Jul  3 09:10:39 kernel: EIP is at cache_clean+0x124/0x1e0
> Jul  3 09:10:39 kernel: eax: 00000000   ebx: 6b6b6b6b   ecx: c06dffa0   edx: c0a1f380
> Jul  3 09:10:39 kernel: esi: f672d800   edi: 00000000   ebp: f5a11f40   esp: f5a11f34
> Jul  3 09:10:39 kernel: ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
> Jul  3 09:10:39 kernel: Process nfsd (pid: 4420, ti=f5a10000 task=f596c070 task.ti=f5a10000)
> Jul  3 09:10:39 kernel: Stack: c06dffa0 f6a3c268 f6a3c234 f5a11f48 c053f69f f5a11f54 c053f6da f6a3c260
> Jul  3 09:10:39 kernel:        f5a11f5c c020ef47 f5a11f70 c0205632 c06597c8 f6a3c268 f6a3c7ac f5a11f94
> Jul  3 09:10:39 kernel:        c0537b23 f59b2000 f5a11f94 00000286 f6a3c270 f59b2000 f6a3c7ac f6a3c234
> Jul  3 09:10:39 kernel: Call Trace:
> Jul  3 09:10:39 kernel:  [<c01054a9>] show_trace_log_lvl+0x19/0x30
> Jul  3 09:10:39 kernel:  [<c010556b>] show_stack_log_lvl+0x8b/0xb0
> Jul  3 09:10:39 kernel:  [<c01057c6>] show_registers+0x1e6/0x310
> Jul  3 09:10:39 kernel:  [<c0105a4f>] die+0x10f/0x240
> Jul  3 09:10:39 kernel:  [<c0115f82>] do_page_fault+0x342/0x610
> Jul  3 09:10:39 kernel:  [<c054d1ac>] error_code+0x7c/0x90
> Jul  3 09:10:39 kernel:  [<c053f69f>] cache_flush+0xf/0x30
> Jul  3 09:10:39 kernel:  [<c053f6da>] cache_purge+0x1a/0x30
> Jul  3 09:10:39 kernel:  [<c020ef47>] nfsd_export_flush+0x17/0x30

So I guess the nfsd export cache is corrupted somehow.

Perhaps turning on more debugging options in the kernel config would
help catch the problem earlier.  I'm not having any luck reproducing
this now.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
