Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:40329 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926Ab1JTCKI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2011 22:10:08 -0400
Received: by ggnb1 with SMTP id b1so2304592ggn.19
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 19:10:07 -0700 (PDT)
Message-ID: <4E9F82FC.2000904@tonian.com>
Date: Wed, 19 Oct 2011 19:10:04 -0700
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/7] Bakeathon server fixes
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's the list of patches I tested here in the Bakeathon.
They pass the Connectathon tests over nfsv4.1 (no pnfs)
against the linux client, but VMware reports a bug with
OPEN with share_access==0x401 (1025)
NFS4_SHARE_WANT_NO_DELEG | NFS4_SHARE_ACCESS_READ
return NFS4ERR_GRACE for some reason.
I haven't been able to track that down yet.

[PATCH 1/7] nfsd4: implement new 4.1 open reclaim types
[PATCH 2/7] nfsd41: use SEQ4_STATUS_BACKCHANNEL_FAULT when
[PATCH 3/7] nfsd4: seq->status_flags may be used unitialized
[PATCH 4/7] nfsd4: allow NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL |
[PATCH 5/7] nfsd4: implement NFS4_SHARE_WANT_NO_DELEG,
[PATCH 6/7] nfsd4: typo logical vs bitwise negate for want_mask
[PATCH 7/7] nfsd4: share_access_to_flags should consider only nfs4.x
