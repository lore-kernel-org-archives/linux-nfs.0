From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: x86_64: 32bit emulation problems
Date: Tue, 1 Mar 2005 00:43:00 +0100
Message-ID: <200503010043.01078.bernd-schubert@web.de>
References: <200502282208.29263.bernd-schubert@web.de> <1109629608.13407.30.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5uXc-0004oT-BN
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 15:43:08 -0800
Received: from smtp08.web.de ([217.72.192.226])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D5uXZ-0005gh-MU
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 15:43:08 -0800
Received: from [84.171.153.249] (helo=[192.168.6.2])
	by smtp08.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.103 #192)
	id 1D5uXQ-0007Xe-00
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 00:42:56 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <1109629608.13407.30.camel@lade.trondhjem.org>
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

On Monday 28 February 2005 23:26, you wrote:
> Given that strace shows that both syscalls (stat64() and stat())
> succeed, I expect the "problem" is probably just glibc setting an
> EOVERFLOW error in the 32-bit case. That's what it is supposed to do if
> a 64 bit value overflows the 32-bit buffers.

Right, thanks. 

>
> Have you tried looking at errno?
>

bernd@hitchcock tests>./test_stat32 /mnt/test/yp
stat for /mnt/test/yp failed
ernno: 75 (Value too large for defined data type)

But why does stat64() on a 64-bit kernel tries to fill in larger data than on 
a 32-bit kernel and larger data also only for nfs-mount points? Hmm, I will 
tomorrow compare the tcp-packges sent by the server.


Many thanks,
 Bernd


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
