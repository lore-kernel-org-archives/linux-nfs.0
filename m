Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp3-g21.free.fr ([212.27.42.3]:34792 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932275Ab2JEVDb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Oct 2012 17:03:31 -0400
Date: Fri, 5 Oct 2012 23:03:02 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS daemon statistics in /proc/net/rpc/nfsd
Message-ID: <20121005230302.15ff87a8@galadriel.home>
In-Reply-To: <20121005202845.GB30139@fieldses.org>
References: <20121005184856.4472a72e@harpe.intellique.com>
	<20121005202845.GB30139@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Fri, 5 Oct 2012 16:28:45 -0400 vous écriviez:

> The trick to answering a question like this is:
> 
> 	git clone
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> cd linux got log -p fs/nfsd/nfssvc.c

Yes, I realise there are several ways to search through the git
history, alas my git-fu is extremely limited because I'm still a
sectator of subversion :)

> There's a file /proc/fs/nfsd/pool_stats that should be useful for the
> same purpose; see the discussion in
> Documentation/filesystems/nfs/knfsd-stats.txt.
> 
> (But note the overloads-avoided number mentioned there had to be
> removed due to reports of a performance regression; we should figure
> out what to do about that.)
> 

Thank you very much, this looks very promising, and makes definitely
more sense than the bizarre decile-distribution of thread usage from
the old system.

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
