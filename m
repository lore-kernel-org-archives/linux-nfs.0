Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:59090 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757837AbaAHXnC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jan 2014 18:43:02 -0500
Date: Wed, 8 Jan 2014 18:42:58 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: client using portmap/rpcbind when port options are given?
Message-ID: <20140108234258.GA11800@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

How come my nfs client is trying to contact portmap when I've given both the
port= and mountport= options? Is it supposed to do that? Nfs3, nolock,
kernel 3.12, nfsutils 1.2.9 on Arch.

Not asking for help debugging this, just asking if this is normal.
