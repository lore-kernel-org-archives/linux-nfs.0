Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:49389 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932687Ab3BNJuf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2013 04:50:35 -0500
Message-ID: <511CB34C.8060409@parallels.com>
Date: Thu, 14 Feb 2013 13:50:04 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "lsf-pc@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>
CC: <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [ATTEND][LSF/MM TOPIC] NFS in containers + future of FUSE
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I've been working actively over the past year to make NFS client and
NFS kernel server be able to work in containers, based on network
namespaces.
While this work is almost done, there are still some specific issues to
discuss and features to to be done.
In particular, I would like to discuss:

* the way to make it possible to lookup dentries from specified root in modules.
This it required for rpciod workqueue to register SUNPRC services in desired
container with it's own root/mount namespace.
Currently this is impossible, because required VFS routines are not
exported to modules.

* possible solutions for NFSd UMH and Legacy trackers containerization

Also, I would like to participate in discussion about future of
FUSE file system development regarding to distributed file-systems support.

-- 
Best regards,
Stanislav Kinsbursky
