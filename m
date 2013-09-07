Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:48967 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758Ab3IGXSR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Sep 2013 19:18:17 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/6] Fix NFSv4 client-side security autonegotiation
Date: Sat, 7 Sep 2013 19:18:07 -0400
Message-ID: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So, it turns out that security autonegotition on the NFSv4 client has been
broken since Linux 3.10. Nobody has noticed so far, and that is probably
because it is broken on the Linux server too...

With this set of patches, the NFS client will track 'sec=', and will
ensure that we do _not_ allow the crossing of mountpoint boundaries that
violate the 'sec=' mount option.
If the user does not set a 'sec=' mount option, the client will use
autonegotiation and try to select the first supported flavour that is
returned by the SECINFO/SECINFO_NO_NAME functions. The problem here is
that the Linux server appears to sort the list of flavours that it
supports, which makes a mockery of export lines of the form:

/export	-sync,no_wdelay,no_subtree_check 192.168.1.10/24 \
		(sec=krb5p:krb5i,rw,sec=krb5:sys,ro)

Normally, I'd expect an export like the above to order krb5p and
krb5i _before_ the krb5 and sys in the response to SECINFO so that
the client will prefer those over the flavours that only allow read
access to the data...

Anyhow, the client should now be ready for the server-side fix...

Cheers
  Trond


Trond Myklebust (6):
  NFS: Clean up the auth flavour array mess
  NFS: Clean up nfs_parse_security_flavors()
  NFSv4: Fix security auto-negotiation
  NFSv4: Disallow security negotiation for lookups when 'sec=' is
    specified
  NFSv4: Allow security autonegotiation for submounts
  NFS: nfs_compare_super shouldn't check the auth flavour unless 'sec='
    was set

 fs/nfs/internal.h      |  2 +-
 fs/nfs/nfs4_fs.h       |  2 +-
 fs/nfs/nfs4client.c    | 20 +++++++++----
 fs/nfs/nfs4getroot.c   |  4 +--
 fs/nfs/nfs4namespace.c | 21 +++++++++++---
 fs/nfs/nfs4proc.c      | 21 ++++++++++----
 fs/nfs/nfs4super.c     |  2 --
 fs/nfs/super.c         | 79 +++++++++++++++++++++++++++++++++-----------------
 8 files changed, 104 insertions(+), 47 deletions(-)

-- 
1.8.3.1

