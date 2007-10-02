From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: NLM mutex deadlock in 2.6.22.9
Date: Tue, 2 Oct 2007 12:31:19 +0200
Message-ID: <20071002103119.GA4641@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Icf26-0002tg-LY
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 03:31:18 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Icf2A-0007IF-Ho
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 03:31:23 -0700
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

nlmsvc_lock() starts out with a

        mutex_lock(&file->f_mutex);

and at some point via the garbage collector it calls mutex_lock()
again. alt-sysrq-t said:

lockd         D ABD55800     0  4462      2 (L-TLB)
       f6849d28 00000046 000ee6b2 abd55800 00000000 c0141ed3 c070daac 00157800 
       f779e900 00000000 f6f08f50 c0898154 f6f08a00 00000000 eefdb7d8 c2a21d80 
       f6f08a00 f6f08b0c 000186a0 3ee72980 000002ab 00000001 00000001 c0573e61 
Call Trace:
 [<c0573f32>] __mutex_lock_slowpath+0xb2/0x250
 [<c0573e61>] mutex_lock+0x21/0x30
 [<c0233ff9>] nlmsvc_traverse_blocks+0x29/0xa0
 [<c0236589>] nlm_traverse_files+0x89/0x240
 [<c02368eb>] nlmsvc_mark_resources+0x1b/0x30
 [<c0233179>] nlm_gc_hosts+0x59/0x1a0
 [<c02326f4>] nlm_lookup_host+0x44/0x350
 [<c0232b3f>] nlmsvc_lookup_host+0x5f/0x70
		nlmsvc_create_block() is inlined
 [<c023433d>] nlmsvc_lock+0x14d/0x360
 [<c023961a>] nlm4svc_proc_lock+0xea/0x140
 [<c05600a0>] svc_process+0x320/0x700
 [<c0233663>] lockd+0x133/0x270
 [<c0105337>] kernel_thread_helper+0x7/0x10

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
