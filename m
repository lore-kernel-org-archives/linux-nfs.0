From: Steven <steven@void.org>
Subject: NFS crash problem in readdirplus
Date: Fri, 01 Apr 2005 09:30:53 -0800
Message-ID: <20050401173053.32F551154F4@dead.void.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DHQ09-00052S-PA
	for nfs@lists.sourceforge.net; Fri, 01 Apr 2005 09:32:09 -0800
Received: from dsl092-218-023.sfo2.dsl.speakeasy.net ([66.92.218.23] helo=chaotic.void.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DHQ08-00059z-Ak
	for nfs@lists.sourceforge.net; Fri, 01 Apr 2005 09:32:09 -0800
Received: from dead.void.org ([192.168.54.11])
	by chaotic.void.org (8.12.10/8.10.2/SuSE Linux 8.10.0-0.3) with ESMTP id j31HI4XD032367
	for <nfs@lists.sourceforge.net>; Fri, 1 Apr 2005 09:18:04 -0800
Received: from dead.void.org (localhost [127.0.0.1])
	by dead.void.org (Postfix) with ESMTP id 32F551154F4
	for <nfs@lists.sourceforge.net>; Fri,  1 Apr 2005 09:30:53 -0800 (PST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


A readdirplus call with count=0 reliably causes a server crash due to a
null pointer dereference.  The relevant information from my 
/var/log/messages is at the end of this message.

I believe this to be caused by the following code;

fs/nfsd/nfs3xdr.c:562:
int
nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, u32 *p,
					struct nfsd3_readdirargs *args)
{
	int len, pn;

	if (!(p = decode_fh(p, &args->fh)))
		return 0;
	p = xdr_decode_hyper(p, &args->cookie);
	args->verf     = p; p += 2;
	args->dircount = ntohl(*p++);
	args->count    = ntohl(*p++);

	len = (args->count > NFSSVC_MAXBLKSIZE) ? NFSSVC_MAXBLKSIZE :
						  args->count;
	args->count = len;

here>	while (len > 0) {
		pn = rqstp->rq_resused;
		svc_take_page(rqstp);
		if (!args->buffer)
			args->buffer = page_address(rqstp->rq_respages[pn]);
		len -= PAGE_SIZE;
	}

	return xdr_argsize_check(rqstp, p);
}

If len is 0 then the while loop is never executed.

Here is my system information.  I have seen this happen on various 2.4
servers as well.

    # cat /proc/version
    Linux version 2.6.5-1.358 (bhcompile@bugs.build.redhat.com) (gcc version 3.3.3 20040412 (Red Hat Linux 3.3.3-7)) #1 Sat May 8 09:04:50 EDT 2004

--Steven

--- /var/log/messages ---

Mar 29 13:26:31 tc47 kernel: Unable to handle kernel NULL pointer dereference at
 virtual address 00000000
Mar 29 13:26:31 tc47 kernel:  printing eip:
Mar 29 13:26:31 tc47 kernel: 42aeef47
Mar 29 13:26:31 tc47 kernel: *pde = 00000000
Mar 29 13:26:31 tc47 kernel: Oops: 0002 [#1]
Mar 29 13:26:31 tc47 kernel: CPU:    0
Mar 29 13:26:31 tc47 kernel: EIP:    0060:[<42aeef47>]    Not tainted
Mar 29 13:26:31 tc47 kernel: EFLAGS: 00010246   (2.6.5-1.358) 
Mar 29 13:26:31 tc47 kernel: EIP is at nfs3svc_encode_readdirres+0x3f/0x89 [nfsd
]
Mar 29 13:26:31 tc47 kernel: eax: 00000000   ebx: 2d690800   ecx: 00000000   edx
: 00000000
Mar 29 13:26:31 tc47 kernel: esi: 2d6908f8   edi: 33e5b080   ebp: 03a92800   esp
: 3fe58f50
Mar 29 13:26:31 tc47 kernel: ds: 007b   es: 007b   ss: 0068
Mar 29 13:26:31 tc47 kernel: Process nfsd (pid: 1190, threadinfo=3fe58000 task=3
cf7f930)
Mar 29 13:26:31 tc47 kernel: Stack: 03a92864 03a92800 42aeef08 33e5b020 42b019e4
 42ae35a6 33e5b018 03a92864 
Mar 29 13:26:31 tc47 kernel:        03a92800 42b01a98 33e5b018 42a7ec24 fffffeff
 00000043 0000010c 00000100 
Mar 29 13:26:31 tc47 kernel:        000186a3 03a92840 42b019e4 42b01a98 42b00ee0
 03948504 00000000 18b7b1a1 
Mar 29 13:26:31 tc47 kernel: Call Trace:
Mar 29 13:26:31 tc47 kernel:  [<42aeef08>] nfs3svc_encode_readdirres+0x0/0x89 [n
fsd]
Mar 29 13:26:31 tc47 kernel:  [<42ae35a6>] nfsd_dispatch+0x117/0x165 [nfsd]
Mar 29 13:26:31 tc47 kernel:  [<42a7ec24>] svc_process+0x323/0x55f [sunrpc]
Mar 29 13:26:31 tc47 kernel:  [<42ae3355>] nfsd+0x18f/0x2c9 [nfsd]
Mar 29 13:26:31 tc47 kernel:  [<42ae31c6>] nfsd+0x0/0x2c9 [nfsd]
Mar 29 13:26:31 tc47 kernel:  [<021041d9>] kernel_thread_helper+0x5/0xb
Mar 29 13:26:31 tc47 kernel: 
Mar 29 13:26:31 tc47 kernel: Code: c7 02 00 00 00 00 81 bb f8 00 00 00 00 00 75 
31 0f 94 c0 0f 




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
