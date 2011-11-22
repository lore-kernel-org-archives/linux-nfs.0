Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39409 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753579Ab1KVW6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 17:58:21 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 0/4] NFS: Modularize NFS v3
Date: Tue, 22 Nov 2011 17:57:59 -0500
Message-Id: <1322002684-20436-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This set of patches removes NFS v3 from the main NFS kernel module and creates
a new module containing the proc, xdr, and acl code.  This will give us a
single directory to put NFS v3 specific code so it doesn't need to be mixed in
with the generic client stuff.

I'm sure this could still use a lot of work, but I figured I would wait to see
what everybody thinks first.  I imagine that once we get an "nfs submodule"
system working it'll be easier to convert v2 and v4 (and possibly v4.1?) to
modules.

I split the second patch into two to make it easier to see what my changes were
to get everything to compile.  Hopefully this will save some pain in having to
look through 7000+ line patch that resulted from my `mv nfs3*.c nfs3/`
command.  I can combine everything in a future version of the patch.

Thoughts?

- Bryan

