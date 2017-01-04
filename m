Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:46432 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751753AbdADTFm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2017 14:05:42 -0500
Date: Wed, 4 Jan 2017 14:03:27 -0500
From: Dave Jones <davej@codemonkey.org.uk>
To: bfields@redhat.com
Cc: jlayton@poochiereds.net, Linux Kernel <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: NFS: SECINFO: security flavor 390003 is not supported
Message-ID: <20170104190327.v3wbpcbqtfa5jy7d@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since upgrading to 4.10-rc2, my nfs server has started printing these..

[  161.668635] NFS: SECINFO: security flavor 390003 is not supported
[  161.668655] NFS: SECINFO: security flavor 390004 is not supported
[  161.668670] NFS: SECINFO: security flavor 390005 is not supported

Client is debian's 4.8 kernel with default mount options, so sec=sys

What should I be doing to suppress these ? What causes them ?

	Dave

