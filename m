From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: [NFS] nfs2/3 ESTALE bug on mount point (v2.6.24-rc8)
Date: Mon, 28 Jan 2008 22:03:48 -0500
Message-ID: <200801290303.m0T33miE028199@agora.fsl.cs.sunysb.edu>
References: <20080129010819.GD16785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>, Trond.Myklebust@netapp.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51566 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754922AbYA2DES (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 22:04:18 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JJglk-0005I4-1E
	for linux-nfs@vger.kernel.org; Tue, 29 Jan 2008 14:04:16 +1100
In-reply-to: Your message of "Mon, 28 Jan 2008 20:08:19 EST."
	<20080129010819.GD16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <20080129010819.GD16785@fieldses.org>, "J. Bruce Fields" writes:
> On Sun, Jan 27, 2008 at 11:37:59PM -0500, Erez Zadok wrote:

> > You can find both an strace and content files in
> > 
> > 	http://agora.fsl.cs.sunysb.edu/tmp/nfs/

Sorry.  I guess tar on /proc files doesn't really save the content of the
files.

I cat'ed the content files and alo placed an updated strace in the above
URL.  Here's the content files.  In this run, I got an ESTALE on
/n/lower/b2:

  mkdir: cannot create directory `/n/lower/b2': Stale NFS file handle

Erez.

::::::::::::::
/proc/net/rpc/auth.unix.gid/content
::::::::::::::
#uid cnt: gids...
# expiry=1201575525 refcnt=1 flags=3
# 0 0:
::::::::::::::
/proc/net/rpc/auth.unix.ip/content
::::::::::::::
#class IP domain
# expiry=1201577204 refcnt=2 flags=1
nfsd 127.0.0.1 localhost.localdomain
# expiry=2147483647 refcnt=1 flags=1
nfsd 0.0.0.0 -test-client-
::::::::::::::
/proc/net/rpc/nfs4.idtoname/content
::::::::::::::
#domain type id [name]
::::::::::::::
/proc/net/rpc/nfs4.nametoid/content
::::::::::::::
#domain type name [id]
::::::::::::::
/proc/net/rpc/nfsd.export/content
::::::::::::::
#path domain(flags)
# expiry=1201577204 refcnt=1 flags=1
/n/export/b5	localhost.localdomain(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=a91d2562:3acf4709:97cf4c71:24c5dcfb)
# expiry=1201577205 refcnt=1 flags=1
/n/export/b6	localhost.localdomain(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=533ab699:d98c46e6:9e3084f6:2b447886)
# expiry=1201577207 refcnt=1 flags=1
/n/export/b1	localhost.localdomain(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=80754c2e:e5984d43:93d59492:65ee9933)
# expiry=1201577206 refcnt=1 flags=1
/n/export/b0	localhost.localdomain(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=6d5e7d95:a33948c3:a3b73aa6:cadaa639)
::::::::::::::
/proc/net/rpc/nfsd.fh/content
::::::::::::::
#domain fsidtype fsid [path]
# expiry=2147483647 refcnt=1 flags=1
localhost.localdomain 6 0x62251da90947cf3a714ccf97fbdcc524 /n/export/b5
# expiry=2147483647 refcnt=1 flags=3
# localhost.localdomain 6 0x0800bfebda4f9d24013f00ba702bbdb6
# expiry=2147483647 refcnt=1 flags=1
localhost.localdomain 6 0x2e4c7580434d98e59294d5933399ee65 /n/export/b1
# expiry=2147483647 refcnt=1 flags=1
localhost.localdomain 6 0x99b63a53e6468cd9f684309e8678442b /n/export/b6
# expiry=2147483647 refcnt=1 flags=1
localhost.localdomain 6 0x957d5e6dc34839a3a63ab7a339a6daca /n/export/b0

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

