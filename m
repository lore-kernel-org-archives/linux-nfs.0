From: Erik Thiele <erik@thiele-hydraulik.de>
Subject: Re: trouble with file locking
Date: Thu, 20 Nov 2003 07:05:31 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031120070531.7886de98.erik@thiele-hydraulik.de>
References: <20031112105043.020c1548.erik@thiele-hydraulik.de>
	<Pine.LNX.4.58.0311191259400.846@lewis.et.byu.edu>
	<shsd6bohzxw.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davidd@et.byu.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMhxH-0000hm-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 22:06:15 -0800
Received: from moutng.kundenserver.de ([212.227.126.185])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AMhwm-000848-LG
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 22:05:44 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsd6bohzxw.fsf@charged.uio.no>
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

On 19 Nov 2003 15:21:31 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> >>>>> " " == David Dougall <davidd@et.byu.edu> writes:
> 
>      > Is this test program run on a HP-UX client or a linux client?
>      > My experience with HP-UX nfs client is that locking is very
>      > flaky if it even works at all.  You might try flock instead of
>      > fcntl.  That seems to work better.  You might also, if you have
>      > a support contract, check out HP-UX nfs patches.  They might
>      > suddenly make it work.  --David Dougall
> 

the program is run on a linux client. the hp-ux clients i only told you
about because they _might_ be disturbing the system in a way that the
other clients don't work anymore.

> flock() doesn't work at all over NFS in Linux. It just does local
> locking.

well, but i saw ethereal showimg me the nfs locking packets.


cu
erik

-- 
Erik Thiele


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
