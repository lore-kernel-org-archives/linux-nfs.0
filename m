From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re: Re: 2.6.3-rc1-mm1
Date: Thu, 12 Feb 2004 17:37:02 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402121737.02690.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ArJp7-0007Hk-L5
	for nfs@lists.sourceforge.net; Thu, 12 Feb 2004 08:36:21 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1ArJnq-000329-VJ
	for nfs@lists.sourceforge.net; Thu, 12 Feb 2004 08:35:03 -0800
Received: from roquetav (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id RAA10620
	for <nfs@lists.sourceforge.net>; Thu, 12 Feb 2004 17:35:44 +0100
To: <nfs@lists.sourceforge.net>
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

> Le Lundi 09 F=E9vrier 2004 15:26, Philippe Gramoull=E9 a =E9crit :
> Sorry, i forgot to CC: this list.
>
> Thanks,
>
> Philippe
>
>
> Hello Andrew,
>
> On Mon, 9 Feb 2004 01:40:35 -0800
>
> Andrew Morton <akpm@osdl.org> wrote:
>   | ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-r=
c1
>   |/2.6.3-rc1-mm1/
>   |
>   |
>   | - NFSD update
>
> Starting with 2.6.3-rc1-mm1, nfsd isn't working any more. Exportfs just
> hangs. Previous version (2.6.2-mm1) worked fine.
> Reverting the following patches makes it work again:
>
> nfsd-01-schedule-in-spinlock-fix.patch
> nfsd-02-ip_map_init-kmalloc-check.patch
> nfsd-03-sunrpc-cache-init-fixes.patch
> nfsd-04-convert-proc-to-seq_file.patch
> nfsd-05-no-procfs-build-fix.patch
>
> You can find my .config here:
>
> http://philou.org/linux/2.6.3-rc1-mm1/config-2.6.3-rc1-mm1
>
> You can find an strace of the nfsd server startup as well as a sysrq-t
> capture here:
>
> http://philou.org/linux/2.6.3-rc1-mm1/nfsd-sysrq.txt
>
> System is a Dell 2650 SMP (ia32), running Debian Sid.
>
> Thanks,
>
> Philippe
>
> --
>
> Philippe Gramoull=E9
> philippe.gramoulle@mmania.com
> Senior System and Network Architect
> Lycos Europe

I have the same problem applying all 2.6.1 patches... I'm trying all 65
patches 1 by one...
Vincent

=2D------------------------------------------------------



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
