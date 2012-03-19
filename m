Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:23047 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754449Ab2CSU6t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 16:58:49 -0400
Message-ID: <4F679E07.1010100@hp.com>
Date: Mon, 19 Mar 2012 21:58:47 +0100
From: Martin Rusko <martin.rusko@hp.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: =?ISO-8859-1?Q?Olle_R=E4msberg_XX?= <olle.xx.ramsberg@ericsson.com>
Subject: "ls -l" hangs again since 2.6.34
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

originally before 2.6.34 kernel there were two lines in nfs_getattr()
function in inode.c file which suspended/resumed process dirtying pages
to allow flush cached changes to NFS server to get mtime/ctime values
set ...

/*
 * Flush out writes to the server in order to update c/mtime.
 *
 * Hold the i_mutex to suspend application writes temporarily;
 * this prevents long-running writing applications from blocking
 * nfs_wb_nocommit.
 */
if (S_ISREG(inode->i_mode)) {
        mutex_lock(&inode->i_mutex);
        nfs_wb_nocommit(inode);
        mutex_unlock(&inode->i_mutex);
}


... however this has been replaced in this commit
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=3fa04ecd72780da31ba8b329e148179bc24a9c7d
and since then again process writing heavily into files on NFS can block
stat calls on these for dozens of seconds.

Is this case, when one process is writing into a file and thus blocking
another process from doing a stat call on it (which means that RPC
GETATTR must be sent and this can't be done before dirty pages are
written to NFS server) handled somewhere in the code, please?

Best Regards,
Martin

PS: Please, Cc me for any reply as I'm not subscribed. Thanks!


