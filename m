From: Ray Ferguson <nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org>
Subject: NFSERR_NOSPC nfs-client bug
Date: Mon, 17 Mar 2008 19:21:08 -0600
Message-ID: <200803172021.08327.nfs@share-foo.com>
Reply-To: nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 71-86-230-38.static.mdsn.wi.charter.com ([71.86.230.38]:47294
	"EHLO gw.share-foo.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbYCRBbF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2008 21:31:05 -0400
Received: from gw.share-foo.com (localhost [127.0.0.1])
	by postfilter.gw.share-foo.net (Postfix) with ESMTP id CA0B728093
	for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2008 20:20:52 -0500 (CDT)
Received: from booger.localdomain (a7v.localdomain [192.168.0.2])
	by gw.share-foo.com (Postfix) with ESMTP id BE62128092
	for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2008 20:20:52 -0500 (CDT)
Received: from localhost (localhost [IPv6:::1])
	by booger.localdomain (Postfix) with ESMTP id 8D9BA1380
	for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2008 20:21:09 -0500 (CDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've discovered a bug in the linux nfs client.  Specifically it ignores 
NFSERR_NOSPC messages (code 28) from an NFS server and happily continues 
pounding it with data.

This causes some rather unfortunate consequences on linux nfs servers by 
exhausting resources.  In 2.4, all cpus peg at 100% usage under the system 
catagory.  In 2.6, at least one core gets pegged at 100% iowait, but this 
still triggers cascading load issues.

So far I've tested:

Opensuse-10.3 = Linux 2.6.22 (client bug confirmed)
RHAS4 = 2.6.9 (client bug confirmed)
RHAS3 = 2.4.21(No Bug: Pre-nfs4)
Solaris 9 = (No Bug)

This can be reproduced by creating a small filesystem and exporting it via 
nfs.  Then mount it with a buggy client and "cat /dev/zero > /nfs-share/foo"

The expected behavior is for the client to error out the write with a message 
informing you that the filesystem is out of space.  Instead, the client keeps 
sending data and the servers kernel take a beating.

I've checked the wire and confirmed that the server is sending the NOSPC 
message back to the client.  Most of my testing has been nfs3 though I did 
some brief testing w/ nfs2 (bug still present).  I have kernel sysrq debug 
data and packet captures if anyone is interested.

If this is not the correct place to report this, I would be grateful if anyone 
could redirect me.

Thank you for your help.

-
Ray Ferguson
