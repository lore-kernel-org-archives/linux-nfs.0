Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:55014 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042Ab2KFKHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Nov 2012 05:07:49 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<sven@gegg.us>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1TVfVb-0002Lr-Qw
	for linux-nfs@vger.kernel.org; Tue, 06 Nov 2012 10:31:48 +0100
Received: from sven  by ultimate100.geggus.net (envelope-from
	<sven@gegg.us>)
	with local (Exim 4.72)
	id 1TVfVY-00067a-6T
	for linux-nfs@vger.kernel.org; Tue, 06 Nov 2012 10:31:44 +0100
Date: Mon, 5 Nov 2012 17:55:01 +0100
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121105165459.GA2958@geggus.net>
References: <k6ebva$1kf$1@ultimate100.geggus.net>
 <20121026171549.GA11806@fieldses.org>
 <20121029094038.GA14836@geggus.net>
 <20121029150203.GB9502@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20121029150203.GB9502@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields schrieb am Montag, den 29. Oktober um 16:02 Uhr:

> I'd be curious to understand what changed on the server to make a
> difference.  I can't think of anything.

OK, I now figured out which commit did cause the problem:

commit 08843b79fb35d33859e0f8f11a7318341076e4d1
Merge: cc8362b 2c142ba
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue Jul 31 14:42:28 2012 -0700

    Merge branch 'nfsd-next' of git://linux-nfs.org/~bfields/linux
    
    Pull nfsd changes from J. Bruce Fields:
     "This has been an unusually quiet cycle--mostly bugfixes and cleanup.
      The one large piece is Stanislav's work to containerize the server's
      grace period--but that in itself is just one more step in a
      not-yet-complete project to allow fully containerized nfs service.
    
      There are a number of outstanding delegation, container, v4 state, and
      gss patches that aren't quite ready yet; 3.7 may be wilder."
    
    * 'nfsd-next' of git://linux-nfs.org/~bfields/linux: (35 commits)
      NFSd: make boot_time variable per network namespace
      NFSd: make grace end flag per network namespace
      Lockd: move grace period management from lockd() to per-net functions
      LockD: pass actual network namespace to grace period management
      functions
      LockD: manage grace list per network namespace
      SUNRPC: service request network namespace helper introduced
      NFSd: make nfsd4_manager allocated per network namespace context.
      LockD: make lockd manager allocated per network namespace
      LockD: manage grace period per network namespace
      Lockd: add more debug to host shutdown functions
      Lockd: host complaining function introduced
      LockD: manage used host count per networks namespace
      LockD: manage garbage collection timeout per networks namespace
      LockD: make garbage collector network namespace aware.
      LockD: mark host per network namespace on garbage collect
      nfsd4: fix missing fault_inject.h include
      locks: move lease-specific code out of locks_delete_lock
      locks: prevent side-effects of locks_release_private before file_lock
      is initialized
      NFSd: set nfsd_serv to NULL after service destruction
      NFSd: introduce nfsd_destroy() helper
      ...

Thus "git diff 08843b79..cc8362b1" on a linux-stable tree from
git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git should
give us the relevant changes.


Regards

Sven

-- 
Das allgemeine Persönlichkeitsrecht (Art. 2 Abs.1 i.V.m. Art.1 Abs. 1GG)
umfasst das Grundrecht auf Gewährleistung der Vertraulichkeit und Integrität
informationstechnischer Systeme. (BVerfG, 1BvR 370/07)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
