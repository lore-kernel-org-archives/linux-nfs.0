From: "Rob Dege" <rcd@amherst.com>
Subject: Kernel paging dump on 2.4.18
Date: Mon, 22 Apr 2002 14:19:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <GKEPJBFFKGJCJDOINKHJMELHCFAA.rcd@amherst.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from odo.amherst.com ([12.19.228.55] helo=mail.amherst.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16ziPF-0005Pj-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 11:19:17 -0700
Received: from nelson (dhcp-51-158.amherst.com [172.28.51.158])
	by mail.amherst.com (8.12.3/8.12.3) with SMTP id g3MIJEge030049
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 14:19:14 -0400
To: "nfs" <nfs@lists.sourceforge.net>
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

I'm running RedHat 7.2 w/2.4.18 as a dedicated file server prmailily for
Linux & alpha machines.  I've been getting kernel paging faults, and don't
know what's causing it.  The odd thing is that the kernel error only affects
NFS.  Everything else is stable, and usable.  here's the dump from
/var/log/messages:

Apr 17 09:25:35 mars kernel: Unable to handle kernel paging request at
virtual address a3af6fb0
Apr 17 09:25:35 mars kernel:  printing eip:
Apr 17 09:25:35 mars kernel: c027466a
Apr 17 09:25:35 mars kernel: *pde = 00000000
Apr 17 09:25:35 mars kernel: Oops: 0002
Apr 17 09:25:35 mars kernel: CPU:    0
Apr 17 09:25:35 mars kernel: EIP:    0010:[xdr_encode_netobj+26/112]    Not
tainted
Apr 17 09:25:35 mars kernel: EIP:    0010:[<c027466a>]    Not tainted
Apr 17 09:25:35 mars kernel: EFLAGS: 00010217
Apr 17 09:25:35 mars kernel: eax: 3733cfd4   ebx: c6e03060   ecx: 01000000
edx: c6e03060
Apr 17 09:25:35 mars kernel: esi: dc4ff480   edi: c6e0304c   ebp: c6726064
esp: de149d80
Apr 17 09:25:35 mars kernel: ds: 0018   es: 0018   ss: 0018
Apr 17 09:25:35 mars kernel: Process lockd (pid: 751, stackpage=de149000)
Apr 17 09:25:35 mars kernel: Stack: 0d000000 de149dbc c0183eff c18076e0
c672606c dc4ff480 c6e0304c c6e03060
Apr 17 09:25:35 mars kernel:        c018fbd9 c6e03060 c6726064 00000085
de148000 c672606c ca1da2c0 c0190570
Apr 17 09:25:35 mars kernel:        ca1da540 c027134a ccb3805c dc4ff480
c0190570 ca1da540 c0190582 c6e0304c
Apr 17 09:25:35 mars kernel: Call Trace: [nlm_fopen+175/224]
[nlm4_encode_testres+137/528] [nlm4clt_encode_testres+0/48] [rpca
uth_marshcred+74/80] [nlm4clt_encode_testres+0/48]
Apr 17 09:25:35 mars kernel: Call Trace: [<c0183eff>] [<c018fbd9>]
[<c0190570>] [<c027134a>] [<c0190570>]
Apr 17 09:25:35 mars kernel:    [nlm4clt_encode_testres+18/48]
[call_encode+203/256] [__rpc_execute+169/704] [rpc_call_setup+5
9/112] [rpc_call_async+118/160] [nlmsvc_async_call+120/144]
Apr 17 09:25:35 mars kernel:    [<c0190582>] [<c026c4db>] [<c026fb19>]
[<c026c15b>] [<c026c0f6>] [<c018a6b8>]
Apr 17 09:25:35 mars kernel:    [nlm4svc_callback_exit+0/80]
[nlm4svc_callback+114/160] [nlm4svc_callback_exit+0/80] [nlm4svc_
proc_test_msg+67/80] [handle_IRQ_event+57/96] [net_rx_action+312/528]
Apr 17 09:25:35 mars kernel:    [<c0190f60>] [<c0190f32>] [<c0190f60>]
[<c0190a73>] [<c0107fa9>] [<c02383c8>]
Apr 17 09:25:35 mars kernel:    [schedule+737/784] [nlm4_decode_lock+70/256]
[nlm4_decode_lock+91/256] [nlm4svc_decode_testarg
s+44/112] [svc_process+703/1248] [lockd+400/592]
Apr 17 09:25:35 mars kernel:    [<c010f941>] [<c018f8f6>] [<c018f90b>]
[<c018fddc>] [<c02720cf>] [<c018b800>]
Apr 17 09:25:35 mars kernel:    [kernel_thread+38/48] [lockd+0/592]
Apr 17 09:25:35 mars kernel:    [<c0105536>] [<c018b670>]
Apr 17 09:25:35 mars kernel:
Apr 17 09:25:35 mars kernel: Code: c7 04 83 00 00 00 00 8b 45 00 0f c8 89 02
8b 45 00 83 c3 04


Any Help is appreciated.

-Rob


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
