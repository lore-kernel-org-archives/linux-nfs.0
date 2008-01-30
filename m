From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 4/4] NFS: Show most mount options via nfs_show_options()
Date: Wed, 30 Jan 2008 13:50:32 +0100
Message-ID: <E1JKCOe-0008Dg-2p@pomaz-ex.szeredi.hu>
References: <20080130001333.14637.74159.stgit@manray.1015granger.net>
Cc: trond.myklebust@fys.uio.no, miklos@szeredi.hu,
	linux-nfs@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:55552 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbYA3Ne2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2008 08:34:28 -0500
In-reply-to: <20080130001333.14637.74159.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
	(message from Chuck Lever on Tue, 29 Jan 2008 19:13:33 -0500)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Display all mount options in /proc/mount which may be needed to reconstruct
> a previous mount.

Thanks, looks good to me.  The only thing I see still missing is
"mounthost".  What about that one?

Miklos
