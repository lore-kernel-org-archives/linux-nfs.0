From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS crash problem in readdirplus
Date: Wed, 20 Apr 2005 16:10:02 -0400
Message-ID: <1114027802.15795.34.camel@lade.trondhjem.org>
References: <20050401173053.32F551154F4@dead.void.org>
	 <20050420084935.GA30863@suse.de> <20050420183438.10F691165A4@dead.void.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOLWk-0004xx-BJ
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 13:10:26 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOLWi-00065R-Qa
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 13:10:26 -0700
To: Steven <steven@void.org>
In-Reply-To: <20050420183438.10F691165A4@dead.void.org>
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

on den 20.04.2005 Klokka 11:34 (-0700) skreiv Steven:

> I think that a maxcount of 0 is an invalid argument.  The rfc says that
> the size must include all XDR overhead so there is no way to reply
> successfully when maxcount is 0.

Note that _strictly_ speaking, maxcount gives the maximum size for the
entire READDIRPLUS3resok structure (including post_op attr and cookie
verifier).
This is something we appear to have overlooked in both the client and
server and applies to READDIR too. It also applies to NFSv4.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
