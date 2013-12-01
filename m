Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59546 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201131441.790963326@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:41 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series tries to get rid of the damage created by sprinkling the
network namespace cat poo all over rpc_pipefs and users.

Instead of getting lost in a maze of notifiers and infrastructure build
around it a cargo cult manner we revert to a slightly nicer version of
the pre-namespace API.

To do this we just have to create an in-kernel instance of rpc_pipefs
that is mounted at network namespace creation so that all functions can
operated on it.

As-is this has one major downside: because the initial mount already grabs
a reference to the network namespace we'll create a cyclic reference and
will never free the network namespace.  To get around this we'd need
some way to only grab it once user mounts show up / disapear in the VFS.

Given that the namespace kraken has infected various internal filesystem
and will get more soon I suspect this problem is or will become generic
and will need a proper solution anyway.  Al, any good ideas how to deal
with this?  Most straight forward way would be to add a counter of
user vfsmount to the superblock and methods when it goes to 1 and 0,
but that seems a bit ugly.
