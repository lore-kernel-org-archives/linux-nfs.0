From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 16] knfsd: Introduction
Date: Mon, 3 Apr 2006 15:18:01 +1000
Message-ID: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964836AbWDCFTu@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Groan, I missed the merge-window, but that's for new features, and this
is bug fixes...

The following 16 patches fix various bugs in the nfs server, mostly
related to NFSv4, but there are a couple that are more generally
applicable (005 in particular).

They are against 2.6.16-mm2 and should be suitable for 2.6.17-rc2.

Thanks,
NeilBrown


 [PATCH 001 of 16] knfsd: locks: flag NFSv4-owned locks
 [PATCH 002 of 16] knfsd: nfsd4: Wrong error handling in nfs4acl
 [PATCH 003 of 16] knfsd: nfsd4: better nfs4acl errors
 [PATCH 004 of 16] knfsd: nfsd4: fix acl xattr length return
 [PATCH 005 of 16] knfsd: nfsd: oops exporting nonexistent directory
 [PATCH 006 of 16] knfsd: nfsd: nfsd_setuser doesn't really need to modify rqstp->rq_cred.
 [PATCH 007 of 16] knfsd: nfsd4: remove nfsd_setuser from putrootfh
 [PATCH 008 of 16] knfsd: nfsd4: fix corruption of returned data when using 64k pages
 [PATCH 009 of 16] knfsd: nfsd4: fix corruption on readdir encoding with 64k pages
 [PATCH 010 of 16] knfsd: svcrpc: gss: don't call svc_take_page unnecessarily
 [PATCH 011 of 16] knfsd: svcrpc: WARN() instead of returning an error from svc_take_page
 [PATCH 012 of 16] knfsd: nfsd4: fix laundromat shutdown race
 [PATCH 013 of 16] knfsd: nfsd4: nfsd4_probe_callback cleanup
 [PATCH 014 of 16] knfsd: nfsd4: add missing rpciod_down()
 [PATCH 015 of 16] knfsd: nfsd4: limit number of delegations handed out.
 [PATCH 016 of 16] knfsd: nfsd4: grant delegations more frequently
