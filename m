From: trond.myklebust@fys.uio.no
Subject: Re: NFS suport block sharing
Date: Thu, 19 Feb 2004 01:04:40 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <33914.207.214.87.84.1077149080.squirrel@webmail.uio.no>
References: <20040218163702.GB31893@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Atbmu-0005o0-T5
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 16:11:32 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Atbht-0008Jl-Qb
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 16:06:22 -0800
To: "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20040218163702.GB31893@suse.de>
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

På on , 18/02/2004 klokka 08:37, skreiv Olaf Kirch:
> To make a long story short, I think _if_ we do NFS super block
> sharing, we should make sure we use don't reuse an existing
> sb if it has different options. Attached is a patch that implements
this, at least for the most common set of options.
>
> Comments?

I'd prefer not.

We should aim only to have 1 super block per filesystem. Anything else
will lead to inode aliasing, and hence potential data corruption problems
when two processes try to write to the same file on different super
blocks.

Is there really any sane application that requires you to have different
rsize/wsize for the same filesystem?

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
