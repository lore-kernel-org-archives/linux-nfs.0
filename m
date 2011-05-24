Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:45644 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab1EXOwa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 10:52:30 -0400
Message-ID: <4DDBC611.3050202@panasas.com>
Date: Tue, 24 May 2011 17:52:01 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCHES 00/12] Mostly a Resend of ALL Bug fixes and SQUASHMEs -
 pnfs-submit 2.6.40 V7
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


As promised I'm resending all accumulated fixes from Benny's last release.
They have been produced in the below order, each fix right after the patch
that it needs to squash into.

* I have split those SQUASHMEs that belong to different patches.
* I have reordered some of benny's patchset and also split one
  patch into two. A patch that had both generic and objects code
  in it. I will resend also these patches the one that got split
  and a one that was reordered. Please see below.

Benny, Trond If you need to I can send the all ready-made patchset
on call. It is right here waiting. If any body needs it. (Just didn't
want to spam the list.

Please don't forget to throw away all the previous, fixes I sent this
includes everything cleaned up.

It is all based on Benny's: [PATCHSET v6 0/26] pnfs for 2.6.40

Here below is the new patchset order interleaved with the patches
I'm resending. Please apply them in that order and SQUASH

These patches that are indented in are left the same as before:

	#pick 87482a8 NFSv4.1: use struct nfs_client to qualify deviceid
	#pick 21a93b1 pnfs: resolve header dependency in pnfs.h
	#pick d322d23 NFSv4.1: make deviceid cache global
	#pick e96d556 NFSv4.1: purge deviceid cache on nfs_free_client
	#pick 839fb76 pnfs: CB_NOTIFY_DEVICEID

pick b97ee18 NFSv4.1: use layout driver in global device cache - Resend
    I'm resending this because I split out the objects code
    to the relevant patch below (I've put it here so to apply the
    fixes)

pick 898c6d6 SQUASHME: Bug in new global-device-cache code
pick c04e8c7 SQUSHME: pnfs: BUG in _deviceid_purge_client
    These two are a resend and a cleanup of the bug fixes I sent

pick c92b213 pnfs: layout_driver MUST set free_deviceid_node if using dev-cache
    This one I also sent. It is not a SQUASHME it needs to be added
    here

	#pick d1dc744 SUNRPC: introduce xdr_init_decode_pages
	#pick 020333f pnfs: Use byte-range for layoutget
	#pick 50a623c pnfs: align layoutget requests on page boundaries
	#pick 899e1e1 pnfs: Use byte-range for cb_layoutrecall
	#pick 24430f8 pnfs: client stats
	#pick e005007 pnfs-obj: objlayoutdriver module skeleton
	#pick e679f1b pnfs-obj: pnfs_osd XDR definitions
pick d1fb331 SQUASHME: pnfs-obj: pnfs_osd_xdr.h Remove server definitions
	Resend + more removed

	#pick 98f3079 pnfs-obj: pnfs_osd XDR client implementation
pick a6d6418 SQUASHME: pnf-obj xdr_cli: Wrong type in comments
    Resend

	#pick c7b5197 pnfs-obj: decode layout, alloc/free lseg
pick 619d431 SQUASHME: objio alloc/free lseg Bugs fixes
    Resend

	#pick 756866c pnfs-obj: objio_osd device information retrieval and caching
pick 45f1e63 SQUASHME: pnfs-obj: use layout driver in global device cache
pick b8b9d0e SQUASHME: pnfs-obj: Bugs in new global-device-cache code
pick d2bff4d SQUASHME: pnfs-obj: objlayout wants to cache devices until unmount
    All these where sent in different patches, here divided properly to
    apply cleanly to the original patch.

	#pick 2f7beef pnfs: alloc and free layout_hdr layoutdriver methods
	#pick 603ceb3 pnfs-obj: define per-inode private structure
	#pick 608f381 pnfs: support for non-rpc layout drivers
pick 8be3eb4 SQUASHME: pnfs: Fall out from: non-rpc layout drivers
    Resend

	#pick 558f335 pnfs-obj: osd raid engine read/write implementation
pick c437fbb SQUASHME: objio read/write patch: Bugs fixes
    Resend properly rebased this time

	#pick db53862 pnfs: layoutreturn
	#pick 6e323de pnfs: layoutret_on_setattr
	#pick 385cc07 pnfs: encode_layoutreturn
	#pick 8eb75c9 pnfs-obj: report errors and .encode_layoutreturn Implementation.
	#pick e5e510b pnfs: encode_layoutcommit
	#pick bf2158f pnfs-obj: objlayout_encode_layoutcommit implementation


