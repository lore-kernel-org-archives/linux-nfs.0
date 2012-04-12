Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:16463 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934463Ab2DLPmS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Apr 2012 11:42:18 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: global openowner_id and lockowner_id
Date: Thu, 12 Apr 2012 11:42:13 -0400
Message-Id: <58E57AF8-1636-4017-93C0-8520488ED866@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Mime-Version: 1.0 (Apple Message framework v1257)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Changing the SETCLIENTID boot verifier so it is global for the whole client exposes a problem with how we allocate state owners.

A quick umount / mount sequence destroys all state on the client.  But since the client now always uses the same boot verifier and nfs_client_id4 string, the server no longer recognizes a client reboot.  FOr a fresh mount, the client may perform a SETCLIENTID, but it is treated as a callback update (state is not purged) if the client's lease has not yet expired.

Our state owners are generated from a pair of ida structures in the nfs_server for that mount.  They always start from zero after a mount operation.  Likewise, the sequence IDs for these state owners are also reset by umount / mount.  Note that each mount point gets a fresh nfs_server, so these structures are not retained across umount / mount.

This means umount / mount with no lease expiry starts to re-play state owners with reset sequence IDs.  Servers don't really care for that behavior.  I have a test case that reliably gets a BAD_SEQID error from a server after a quick umount / mount followed by a single file creation.

Now that we are about to switch to using more-or-less global SETCLIENTID boot verifiers, it seems to me that we really want a global openowner_id and lockowner_id as well.

The performance impact of such a change might be acceptable because we cache and reuse state owners now.

Thoughts?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




