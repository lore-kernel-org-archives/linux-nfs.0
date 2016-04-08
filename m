Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60426 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757253AbcDHSlN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Apr 2016 14:41:13 -0400
Date: Fri, 8 Apr 2016 14:41:11 -0400
To: Holger =?utf-8?Q?Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Strange "SECINFO: security flavor .." messages
Message-ID: <20160408184111.GB25179@fieldses.org>
References: <pan$2228f$c97142f2$8c4f16d6$23d82166@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <pan$2228f$c97142f2$8c4f16d6$23d82166@googlemail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 07, 2016 at 10:38:55PM +0000, Holger Hoffstätte wrote:
> Hi,
> 
> After restarting my server and a client re-automounts, I see the
> following in the server's dmesg:
> 
> [  706.454187] NFS: SECINFO: security flavor 390003 is not supported
> [  706.454621] NFS: SECINFO: security flavor 390004 is not supported
> [  706.455057] NFS: SECINFO: security flavor 390005 is not supported
> 
> I've been completely unsuccessful in trying to discern what these
> mean and how I can get rid of them; they don't seem to be harmful
> since everything else works just fine, and has done so for years.
> I think this started with NFS 4.2 not too long ago, but don't remember
> for certain. The server exports several mounts, ext4 and xfs.
> Clients use only NFS v4 via automount. All on 4.4.6.

What does "exportfs -v" say?  What about "cat
/proc/net/rpc/nfsd.export/content" right after the client's
mount/remount?
