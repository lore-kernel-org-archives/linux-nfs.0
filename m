From: Matthias Andree <matthias.andree@gmx.de>
Subject: Re: stale NFS file handle (2.4.20) ext3 LVM
Date: Fri, 20 Jun 2003 16:11:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030620141126.GA18438@merlin.emma.line.org>
References: <m3isr2kanm.fsf@merlin.emma.line.org> <3EF1CC36.8F3EC825@moving-picture.com> <m38yrx3dhx.fsf@merlin.emma.line.org> <3EF2D54C.73B9EDAA@moving-picture.com> <20030620111408.GC8061@merlin.emma.line.org> <16115.20684.513868.459583@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from krusty.dt.e-technik.uni-dortmund.de ([129.217.163.1] ident=postfix)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19TMc2-0001v8-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 07:11:34 -0700
Received: from m2a2.dyndns.org (krusty.dt.e-technik.uni-dortmund.de [129.217.163.1])
	by mail.dt.e-technik.uni-dortmund.de (Postfix) with ESMTP id 2C672A381D
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 16:11:28 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <16115.20684.513868.459583@gargle.gargle.HOWL>
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

On Sat, 21 Jun 2003, Neil Brown wrote:

> Nope.   NFS - the protocol - is stateless (Except for the state file
>                files stored on the fileserver....)
>         MOUNTD and NLM are separate supporting protocols, neither of
>                which are stateless.

I am aware that there is state preserved, and preserving state in itself
isn't bad, it's just if a reboot without changing obvious configuration
makes mounts stale without apparent reason, that's annoying.

> and "nfsd" is a program, not a protocol.  What does it mean for a
> program to be stateless?

To have only one trunk for control flow perhaps? :-> Well, seriously,
I'll watch if rmtab confuses the clients.

-- 
Matthias Andree


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
