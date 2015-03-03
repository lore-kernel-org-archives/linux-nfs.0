Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.piware.de ([37.120.164.117]:44482 "EHLO mail.piware.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755990AbbCCR2U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 12:28:20 -0500
From: Martin Pitt <martin.pitt@ubuntu.com>
To: linux-nfs@vger.kernel.org
Cc: systemd-devel@lists.freedesktop.org
Subject: [PATCH 0/2] some systemd unit changes
Date: Tue,  3 Mar 2015 18:28:08 +0100
Message-Id: <1425403690-23847-1-git-send-email-martin.pitt@ubuntu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello NFS developers,

reposting the two patches inline as requested by Steve.

I'm currently systemd-ifying our nfs-utils Ubuntu package. For testing I put
the NFS server and client (i. e. localhost:/foo/bar mounts) on the same
machine. With that I get long hangs during shutdown on stopping the NFS .mount
units, as when that happens the NFS server is already shut down.

This is certainly a corner case as you'd usually not NFS-mount a share from
localhost; but fixing it is relatively simple with the first patch, which makes
sure that if NFS server and client are installed, the server starts before the
client, and the client stops before the server.

For a client without installed server this is harmless as Before= does not
imply a dependency. Likewise, for an NFS server which does not mount shares by
itself, it's also a no-op as remote-fs.target is empty. This would only
slightly reorder the boot sequence for machines which both are an NFS server
and have some remote NFS mounts, but I don't see an issue with that.

The second patch make NFS start earlier in the boot (i. e. before
basic.target), so that you can do things like put /var/ on NFS, or have rcS
SysV init scripts which depend on $remote_fs work. I tested this on both a
server and a client. This is certainly a bit more intrusive, but could be
worthwhile; what do you think?

Thanks for considering,

Martin

