Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754162Ab1BHNqh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 08:46:37 -0500
From: Karel Zak <kzak@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: mount.nfs libmount support
Date: Tue,  8 Feb 2011 14:45:15 +0100
Message-Id: <1297172717-26431-1-git-send-email-kzak@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hi Chuck,

this is the first version of the mount.nfs with libmount support. The code
depends on the latest util-linux code from upstream git tree, or you can 
wait few days for official 2.19 util-linux tarballs (and Fedora binary rpms).

I have tested:

	mount.nfs server://path /mountpoint
	mount.nfs server://path /mountpoint -o remount,ro
	mount.nfs server://path /mountpoint -o user

	umount.nfs server://path
	umount.nfs /mountpoint

.. works for me. For more information see the second patch.

	Karel

