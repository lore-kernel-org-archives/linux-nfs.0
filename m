From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 0/6] Fix several issues with NFS mount option parsing
Date: Wed, 30 Apr 2008 11:59:33 -0400
Message-ID: <20080430154011.32402.42101.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.248]:33449 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbYD3P7i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2008 11:59:38 -0400
Received: by hs-out-0708.google.com with SMTP id 4so444321hsl.5
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2008 08:59:38 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff-

Here's the kind of changes I'm thinking about for addressing some recently
noticed problems with text-based mounts.

These patches should address the following issues:

 o  The retrans= and timeo= settings don't have any effect if they are
    specified before proto=

 o  If UDP is blocked, specifying "proto=tcp" doesn't work because the
    kernel still uses mountproto=udp by default

 o  Sloppy mount options aren't ever allowed, so automounter maps that
    contain options that aren't supported on Linux cause failed mounts

I think there are still important corner cases that aren't working as
well as they should, but this ought to be a good start.

-- 
corporate:    <chuck dot lever at oracle dot com>
