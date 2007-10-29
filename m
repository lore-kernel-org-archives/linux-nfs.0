From: Quentin Godfroy <godfroy@clipper.ens.fr>
Subject: NFSD3 : oops with sec=krb5 and RPCSEC_GSS_KRB5 not compiled in
Date: Tue, 30 Oct 2007 00:35:30 +0100
Message-ID: <20071029233530.GA21043@goelette.ens.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ime8y-0004Oy-4J
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 16:35:40 -0700
Received: from nef2.ens.fr ([129.199.96.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ime92-0004vg-7D
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 16:35:45 -0700
Received: from clipper.ens.fr (clipper-gw.ens.fr [129.199.1.22])
	by nef2.ens.fr (8.13.6/1.01.28121999) with ESMTP id l9TNZVPd066921
	for <nfs@lists.sourceforge.net>; Tue, 30 Oct 2007 00:35:31 +0100 (CET)
Received: from goelette.ens.fr (root@goelette [129.199.129.6]) by
	clipper.ens.fr (8.13.1/jb-1.1)
	id l9TNZUfs010698 for <nfs@lists.sourceforge.net>;
	Tue, 30 Oct 2007 00:35:30 +0100 (MET)
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

Hi,

on a 2.6.22.6, when trying to change an already mounted nfsv3 export from
sec=sys to sec=krb5, with CONFIG_RPCSEC_GSS_KRB5 not compiled in (which
meant that the rps.svcgssd service was refusing to run), i got the
following oops on the server side :

>BUG: unable to handle kernel NULL pointer dereference at virtual address
>00000008
> printing eip:
>d0af084b
>*pde = 00000000
>Oops: 0000 [#1]
>Modules linked in: nfsd exportfs lockd nfs_acl sunrpc ipt_LOG ipt_recent
>ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables ipv6 ebtable_broute
>ebtable_nat ebtable_filter ebtables tcp_diag inet_diag floppy uhci_hcd
>iTCO_wdt usbcore
>CPU:    0
>EIP:    0060:[<d0af084b>]    Not tainted VLI
>EFLAGS: 00010246   (2.6.22.6-pluton #1)
>EIP is at encode_fsid+0x7b/0xa0 [nfsd]
>eax: c58ed0e0   ebx: c9ebb004   ecx: 00000000   edx: 00000002
>esi: c1f58048   edi: c9ebb0ec   ebp: c9ebb004   esp: c599ff18
>ds: 007b   es: 007b   fs: 0000  gs: 0000  ss: 0068
>Process nfsd (pid: 13237, ti=c599e000 task=cbea9a50 task.ti=c599e000)
>Stack: 00000000 c1f58038 d0af0922 c9d7cb40 d0aeeeef 00000000 c9ec4000
>d0af1e30 
>       d0b0f464 c1f58014 d0af1e50 c9ebb0ec c9ec4000 d0ae327f c9ec4000
>cb01a504 
>       c9ec4000 c1f58000 c9ec4000 00000000 c9ebb138 cab1f480 d0a89a34
>c9ec4000 
>Call Trace:
> [<d0af0922>] encode_fattr3+0xb2/0x140 [nfsd]
> [<d0aeeeef>] nfsd3_proc_getattr+0xff/0x110 [nfsd]
> [<d0af1e30>] nfs3svc_encode_attrstat+0x0/0x40 [nfsd]
> [<d0af1e50>] nfs3svc_encode_attrstat+0x20/0x40 [nfsd]
> [<d0ae327f>] nfsd_dispatch+0xef/0x200 [nfsd]
> [<d0a89a34>] svc_process+0x444/0x7e0 [sunrpc]
> [<c010496b>] common_interrupt+0x23/0x28
> [<d0ae3895>] nfsd+0x155/0x260 [nfsd]
> [<d0ae3740>] nfsd+0x0/0x260 [nfsd]
> [<c0104aeb>] kernel_thread_helper+0x7/0x1c
> =======================
>Code: c3 8b 83 88 00 00 00 8b 48 30 89 cb c1 fb 1f 89 d8 0f c8 89 06 89 c8
>0f c8 89 46 04 8d 46 08 5b 5e c3 8b 83 88 00 00 00 8b 48 34 <8b> 59 08 8b 01
>8b 51 04 31 d8 8b 59 0c 0f c8 89 46 04 8d 46 08 
>EIP: [<d0af084b>] encode_fsid+0x7b/0xa0 [nfsd] SS:ESP 0068:c599ff18


Moreover, all the other exported mounts freezed instantly, and the only
solution was to reboot the server.

The configure file is on
http://www.eleves.ens.fr/home/godfroy/config-2.6.22.6

Quentin Godfroy

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
