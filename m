From: "Timothy G. Wesemann" <timwese@voicenet.com>
Subject: Re: nfs: server X not responding (+new problem...)
Date: Tue, 4 Nov 2003 11:07:12 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <03b201c3a2ed$ba65abc0$de0167cf@voicenet.com>
References: <B9F4645CD7B0D511BE8300508B68C327025EAD17@tnscapp02.pcacorp.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AH3iX-0002l8-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Nov 2003 08:07:41 -0800
Received: from mail09.voicenet.com ([207.103.0.43])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AH3iX-0000TH-5y
	for nfs@lists.sourceforge.net; Tue, 04 Nov 2003 08:07:41 -0800
To: <nfs@lists.sourceforge.net>
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

RE: [NFS] nfs: server X not responding, still trying> FWIW, I've found 32K
rsize/wsize to be too agressive for UDP based
> NFS even on an uncongested 100BaseT FD switch

Thanks for the advice, Colin. I've brought them down to 16384, and will
monitor them closely and "work them down" as necessary.

I've got another problem now (perhaps related to the first one). I have 4
clients with 1 type of motherboard/cpu which work fine and another with 3
with *slightly* different hardware (presently all machines are slackware
9.0; nfs-utils-1.0.6; 2.4.20 kernel). Only the last set of these three
identical machines are having daily nfs-related kernel panic problems, and
are intel chipset mobos with "Ethernet Pro 100" NIC's. See ksymoops output
below:

========================================
>>EIP; c01866cc <xdr_decode_fattr+2c/160>   <=====
Trace; c0187c6c <nfs3_xdr_writeres+8c/f0>
Trace; c0187be0 <nfs3_xdr_writeres+0/f0>
Trace; c0239201 <call_decode+d1/1a0>
Trace; c023c91a <__rpc_execute+10a/2f0>
Trace; c0111d73 <schedule+203/350>
Trace; c023cc0d <__rpc_schedule+8d/130>
Trace; c023d400 <rpciod+a0/220>
Trace; c01073f2 <ret_from_fork+6/20>
Trace; c01057ce <kernel_thread+2e/40>
Trace; c023d360 <rpciod+0/220>
Code;  c01866cc <xdr_decode_fattr+2c/160>
00000000 <_EIP>:
Code;  c01866cc <xdr_decode_fattr+2c/160>   <=====
   0:   89 57 1c                  mov    %edx,0x1c(%edi)   <=====
Code;  c01866cf <xdr_decode_fattr+2f/160>
   3:   8b 10                     mov    (%eax),%edx
Code;  c01866d1 <xdr_decode_fattr+31/160>
   5:   0f ca                     bswap  %edx
Code;  c01866d3 <xdr_decode_fattr+33/160>
   7:   83 c0 04                  add    $0x4,%eax
Code;  c01866d6 <xdr_decode_fattr+36/160>
   a:   81 e2 ff 0f ff ff         and    $0xffff0fff,%edx
Code;  c01866dc <xdr_decode_fattr+3c/160>
  10:   09 da                     or     %ebx,%edx
Code;  c01866de <xdr_decode_fattr+3e/160>
  12:   31 db                     xor    %ebx,%ebx
========================================

Has anyone here ever had these apparently hardware-or-driver-related
problems before?

--
Tim Wesemann



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
