Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46553 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756470Ab2D3Tq0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 15:46:26 -0400
Date: Mon, 30 Apr 2012 15:46:25 -0400
To: Zack Perry <zack.perry@sbcglobal.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: To start testing Linux pNFS server?
Message-ID: <20120430194625.GA20420@fieldses.org>
References: <1335679256.79612.YahooMailClassic@web181019.mail.ne1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1335679256.79612.YahooMailClassic@web181019.mail.ne1.yahoo.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 28, 2012 at 11:00:56PM -0700, Zack Perry wrote:
> Hi,
> 
> This is my first message to this list. I have been using Fedora 16 and NFSv4 for sometime, and would like to give NFSv4.1 with the pNFS extension a try.  
> 
> I understand that according to  http://wiki.linux-nfs.org/wiki/index.php/NFSv41_Introduction NFSv4.1 is really developer-only at this point, but it should "mostly work" - that's good enough for me. 
> 
> The wiki http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd, states that "As of early 2011, it is mostly unmaintained, and we no longer recommend its use". It then points to http://wiki.linux-nfs.org/wiki/index.php/PNFS_server_projects. But, as far as spNFS is concerned, the two wiki pages form a circular reference. The other options for file layout are no go either.
> 
> Then, there is this: http://wiki.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions
> which seems to indicate that with a pNFS enabled kernel, a determined user can start testing NFSv4.1 + pNFS. Steve Dickson even has a repository here: http://steved.fedorapeople.org/repos/pnfs/devel/x86_64/rpms/
> 
> Can anyone kind enough to give a short summary as to how to proceed for testing NFSv4.1 + pNFS using Fedora 16 nodes as servers?

My impression is that the most likely to work possibilities are either
the exofs-based or gfs2-based servers.  Boaz Harosh might be able to
help with the latter.  I don't know if the wiki instructions are up to
date.  You probably need to build a kernel from Benny's git tree in
either case.

--b.

> 
> As of now, all my Fedora 16 nodes have the following from a regular kickstart install:
> [root@fedora0 ~]# uname -a
> Linux fedora0 3.3.2-6.fc16.x86_64 #1 SMP Sat Apr 21 12:43:20 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux
> [root@fedora0 ~]# rpm -q nfs-utils
> nfs-utils-1.2.5-5.fc16.x86_64
> [root@fedora0 ~]# cat /proc/fs/nfsd/versions
> +2 +3 +4 -4.1
> 
> Thanks,
> 
> Zack
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
