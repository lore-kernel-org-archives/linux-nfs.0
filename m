From: Per Olofsson <pelle@dsv.su.se>
Subject: NFSv3+Krb5 and mountd
Date: Tue, 24 Aug 2004 20:41:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040824184138.GB3251@nasse>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzgEv-0001Ty-1x
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 11:41:49 -0700
Received: from amsfep17-int.chello.nl ([213.46.243.15])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BzgEt-0003GA-Cw
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 11:41:48 -0700
Received: from localhost ([213.89.140.172]) by amsfep17-int.chello.nl
          (InterMail vM.6.00.05.02 201-2115-109-103-20031105) with ESMTP
          id <20040824184139.VMYJ7145.amsfep17-int.chello.nl@localhost>
          for <nfs@lists.sourceforge.net>; Tue, 24 Aug 2004 20:41:39 +0200
Received: from pelle by localhost with local (Exim 4.34)
	id 1BzgEk-0000rs-4N
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 20:41:38 +0200
To: nfs@lists.sourceforge.net
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

Hi,

I'm trying to use NFSv3 with Kerberos 5. I'm using Debian sarge with
Linux 2.6.7, nfs-utils 1.0.6 with the CITI_NFS4_ALL-13 patch, and
util-linux mount 2.12 with the CITI_NFS4_ALL patch.

I added the following definition to /etc/exports:

/tmpexp gss/krb5(rw)

Then, on the client, I run:

# mount -osec=krb5 oberon:/tmpexp /mnt
mount: oberon:/tmpexp failed, reason given by server: Permission denied

and it fails. According to the log:

Aug 23 19:17:48 oberon rpc.mountd: refused mount request from
mallinux.dsv.su.se for /tmpexp (/): not exported

Now, I add the client machine's name to /etc/exports:

/tmpexp gss/krb5(rw) mallinux(ro)

And it works! I can tell that it uses Kerberos because I can write to
the mounted fs if I have a ticket, but not without. The drawback is
that I am now allowing AUTH_SYS mounting as well, which I want to
avoid. Is this a bug in mountd? Is it difficult to fix?

-- 
Pelle


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
