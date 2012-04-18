Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:49356 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab2DRL0O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Apr 2012 07:26:14 -0400
Date: Wed, 18 Apr 2012 12:26:10 +0100
From: Luis Henriques <luis.henriques@canonical.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Regretion on NFS in mainline kernel
Message-ID: <20120418112610.GA3979@zeus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We have a bug reporting a regression in mainline kernel.  Basically, the
bug reporters are seeing lots of messages:

[ 48.701213] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[ 48.701990] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[ 53.696076] nfs4_reclaim_open_state: 6440 callbacks suppressed

This happens when mounting a user's home directory over NFS.

Is this a known issue being addressed at the moment?  Is there any
information needed to help debugging the issue?

The original bug report can be found here:

http://bugs.launchpad.net/bugs/974664

And there's also a similar report for Fedora:

https://bugzilla.redhat.com/show_bug.cgi?id=811138

Cheers,
--
Luis
