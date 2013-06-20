Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:58040 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965182Ab3FTMJL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Jun 2013 08:09:11 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Updfp-0007p5-H5
	for linux-nfs@vger.kernel.org; Thu, 20 Jun 2013 14:09:09 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1Updfn-0002sJ-Lg
	for linux-nfs@vger.kernel.org; Thu, 20 Jun 2013 14:09:07 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Date: Thu, 20 Jun 2013 12:09:07 +0000 (UTC)
Message-ID: <kpurd3$akk$1@ultimate100.geggus.net>
References: <kpscp8$fo3$1@ultimate100.geggus.net> <20130619213412.GA2547@fieldses.org> <20130620080354.GA5591@geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sven Geggus <lists@fuchsschwanzdomain.de> wrote:

> Unfortunately I was unable to do a git bisect because somewhere on the way
> the behaviour changed from locking to "permission denied".

I now just decided, that broken behaviour has to be treated as broken,
regardles of the kind of behaviour thus my git bisect now ended here:

683428fae8c73d7d7da0fa2e0b6beb4d8df4e808 is the first bad commit
commit 683428fae8c73d7d7da0fa2e0b6beb4d8df4e808
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Sat Feb 2 01:40:53 2013 -0800

    sunrpc: Update svcgss xdr handle to rpsec_contect cache
    
    For each received uid call make_kuid and validate the result.
    For each received gid call make_kgid and validate the result.
    
    Cc: "J. Bruce Fields" <bfields@fieldses.org>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

:040000 040000 15a764b57c7d75a102296c1d151a244e6ec074c964a3a6f19b5a2a4aaf15002b476664d19e68e205 M	net

Note, that this is the one which caused permission denied errors rather than
infinite hangs:
mount.nfs4: access denied by server while mounting vnfsrv:/storage

I suspect that it has been "fixed" in a way which is also broken.

Regards

Sven

-- 
"C Is Quirky, Flawed, And An Enormous Success."
(Dennis M. Ritchie)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
