Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:32925 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510Ab1LNXW7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2011 18:22:59 -0500
Date: Wed, 14 Dec 2011 23:22:54 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Maxim Uvarov <maxim.uvarov@oracle.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org,
        Trond.Myklebust@netapp.com, john@johnmccutchan.com, rlove@rlove.org,
        eparis@parisplace.org
Subject: Re: [PATCH] NFS/INOTIFY: inotify user when deleting files on nfs
Message-ID: <20111214232254.GP2203@ZenIV.linux.org.uk>
References: <1323903495-4084-1-git-send-email-maxim.uvarov@oracle.com>
 <1323903495-4084-2-git-send-email-maxim.uvarov@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323903495-4084-2-git-send-email-maxim.uvarov@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 14, 2011 at 02:58:15PM -0800, Maxim Uvarov wrote:
> This issue was introduced with LTP inotify02 test.
> If file system is not NFS user inotify application
> gets IN_DELETE event. But on NFS code avoids d_delete()
> which sends this event. This patch makes notification
> on NFS the same as non-NFS. I.e. vfs_unlink still avoids
> deletion but it sends event for NFS sillyrenamed files.
> More details here:
> https://lkml.org/lkml/2011/11/29/421

NAK.  Too damn ugly.  And completely misses the point of inotify -
seeing events generated only by this client is going to be worthless.
Face it, inotify is broken by design for network filesystems.  Any
software using it on NFS is broken; trying to paper over that is
not a good idea.

Just.  Don't.  Use.  That.  Shit.
