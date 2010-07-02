Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from messager.iut-bm.univ-fcomte.fr ([194.57.86.195]:42619 "EHLO
	messager.iut-bm.univ-fcomte.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754592Ab0GBIKA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 04:10:00 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by messager.iut-bm.univ-fcomte.fr (Postfix) with ESMTP id AA26A2B47B
	for <linux-nfs@vger.kernel.org>; Fri,  2 Jul 2010 10:01:39 +0200 (CEST)
Received: from messager.iut-bm.univ-fcomte.fr ([127.0.0.1])
	by localhost (messager.iut-bm.univ-fcomte.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qkY5sAp7P-g3 for <linux-nfs@vger.kernel.org>;
	Fri,  2 Jul 2010 10:01:37 +0200 (CEST)
Received: from powwow.iut-bm.univ-fcomte.fr (powwow.iut-bm.univ-fcomte.fr [193.52.61.133])
	by messager.iut-bm.univ-fcomte.fr (Postfix) with ESMTPS id 9C5BD2B478
	for <linux-nfs@vger.kernel.org>; Fri,  2 Jul 2010 10:01:37 +0200 (CEST)
Received: from giersch by powwow.iut-bm.univ-fcomte.fr with local (Exim 4.72)
	(envelope-from <arnaud.giersch@iut-bm.univ-fcomte.fr>)
	id 1OUbBp-00044p-Iy
	for linux-nfs@vger.kernel.org; Fri, 02 Jul 2010 10:01:37 +0200
From: Arnaud Giersch <arnaud.giersch@iut-bm.univ-fcomte.fr>
To: linux-nfs@vger.kernel.org
Subject: Empty core dumps on NFSv4 mounts
Date: Fri, 02 Jul 2010 10:01:37 +0200
Message-ID: <wwezkyas466.fsf@powwow.iut-bm.univ-fcomte.fr>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

On NFSv4 mounts, many core dumps are empty, although ulimit -c is
unlimited.  An ls command shortly after the core dump often shows
4294967294 (2^32-2) as UID and GID for the "core" file.

This only happens when there was no "core" file before the dump.  If a
"core" file owned by the current user is already present, it is
correctly filled.

After having done a git bisect, it seems that the problem was
introduced by commit 80e52aced138bb41b045a8595a87510f27d8d8c5
(NFSv4: Don't do idmapper upcalls for asynchronous RPC calls).

If I understand correctly what happens, do_coredump() [fs/exec.c] fails
because (inode->i_uid != current_fsuid()).  In fact inode->i_uid equals
-2, because decode_attr_owner() [fs/nfs/nfs4xdr.c], which is called from
nfs4_xdr_dec_open() via decode_getfattr(), returns without calling
nfs_map_to_uid(), since its may_sleep parameter is false.

I however do not clearly understand what the aforementioned commit is
supposed to fix.  I read the linux-nfs mailing list archive, and tried
some google search, but I didn't find anything.

Regards,

        Arnaud Giersch
