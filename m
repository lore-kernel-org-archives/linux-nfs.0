Return-Path: linux-nfs-owner@vger.kernel.org
Received: from trent.utfs.org ([94.185.90.103]:40003 "EHLO trent.utfs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121Ab3HOE3h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Aug 2013 00:29:37 -0400
Date: Wed, 14 Aug 2013 21:29:18 -0700 (PDT)
From: Christian Kujau <lists@nerdbynature.de>
To: Dave Kleikamp <dave.kleikamp@oracle.com>
cc: "J. Bruce Fields" <bfields@fieldses.org>, Karl Schmidt <karl@xtronics.com>,
        Jonathan McDowell <noodles@earth.li>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        Ben Hutchings <ben@decadent.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] jfs: avoid misuse of cookie value of 2
In-Reply-To: <520C50F7.3010209@oracle.com>
Message-ID: <alpine.DEB.2.10.1308142122550.7081@trent.utfs.org>
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org> <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org> <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org>
 <20130812162924.GB2395@fieldses.org> <520C50F7.3010209@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Aug 2013 at 22:54, Dave Kleikamp wrote:
> It looks like the problem is that jfs was using a cookie value of 2 for
> a real directory entry, where NFSv4 expect 2 to represent "..". This
> patch has so far only been lightly tested.

Hm, a first compile of 3.11-rc5 errors out with:

  CC [M]  fs/jfs/jfs_dtree.o
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c: In function ‘add_index’:
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:493:13: error: invalid storage class for function ‘free_index’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:493:1: warning: ISO C90 forbids mixed declarations and code [-Wdeclaration-after-statement]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:521:13: error: invalid storage class for function ‘modify_index’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:546:12: error: invalid storage class for function ‘read_index’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:927:12: error: invalid storage class for function ‘dtSplitUp’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:1327:12: error: invalid storage class for function ‘dtSplitPage’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:1639:12: error: invalid storage class for function ‘dtExtendPage’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:1872:12: error: invalid storage class for function ‘dtSplitRoot’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:2234:12: error: invalid storage class for function ‘dtDeleteUp’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:2744:12: error: invalid storage class for function ‘dtRelink’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:2915:13: error: invalid storage class for function ‘add_missing_indices’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:2982:34: error: invalid storage class for function ‘next_jfs_dirent’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:3333:12: error: invalid storage class for function ‘dtReadFirst’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:3405:12: error: invalid storage class for function ‘dtReadNext’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:3581:12: error: invalid storage class for function ‘dtCompare’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:3657:12: error: invalid storage class for function ‘ciCompare’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:3765:12: error: invalid storage class for function ‘ciGetLeafPrefixKey’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:3832:13: error: invalid storage class for function ‘dtGetKey’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:3896:13: error: invalid storage class for function ‘dtInsertEntry’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:4054:13: error: invalid storage class for function ‘dtMoveEntry’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:4255:13: error: invalid storage class for function ‘dtDeleteEntry’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:4350:13: error: invalid storage class for function ‘dtTruncateEntry’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:4430:13: error: invalid storage class for function ‘dtLinelockFreelist’
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:4565:1: error: expected declaration or statement at end of input
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c: At top level:
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:152:12: warning: ‘dtSplitUp’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:155:12: warning: ‘dtSplitPage’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:158:12: warning: ‘dtExtendPage’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:161:12: warning: ‘dtSplitRoot’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:164:12: warning: ‘dtDeleteUp’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:167:12: warning: ‘dtRelink’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:169:12: warning: ‘dtReadFirst’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:171:12: warning: ‘dtReadNext’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:174:12: warning: ‘dtCompare’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:176:12: warning: ‘ciCompare’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:179:13: warning: ‘dtGetKey’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:182:12: warning: ‘ciGetLeafPrefixKey’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:185:13: warning: ‘dtInsertEntry’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:188:13: warning: ‘dtMoveEntry’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:192:13: warning: ‘dtDeleteEntry’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:194:13: warning: ‘dtTruncateEntry’ used but never defined [enabled by default]
/usr/local/src/linux-git/fs/jfs/jfs_dtree.c:196:13: warning: ‘dtLinelockFreelist’ used but never defined [enabled by default]
make[7]: *** [fs/jfs/jfs_dtree.o] Error 1
make[7]: *** Waiting for unfinished jobs....
  CC      drivers/acpi/acpica/utmutex.o
  CC      drivers/acpi/acpica/utobject.o
make[6]: *** [fs/jfs] Error 2
make[5]: *** [fs] Error 2
make[5]: *** Waiting for unfinished jobs....


I'll run mrproper and try again...

Christian.
-- 
BOFH excuse #219:

Recursivity.  Call back if it happens again.
