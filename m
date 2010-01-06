Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932552Ab0AFSXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 13:23:43 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] nfs41: return correct errors on callback replays
Date: Wed,  6 Jan 2010 13:23:28 -0500
Message-Id: <1262802213-2267-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


The first three patches clean up callback processing
0001-nfs41-fix-wrong-error-on-callback-decode-hdr-overflo.patch
0002-nfs41-directly-encode-back-channel-error.patch
0003-nfs41-remove-uneeded-checks-in-callback-processing.patch

These next two implement correct error returns for v4.1 callback replays.
Since our back channel has a ca_maxrequestsize_cached = 0, a replay with
cachethis set to true results in a NFS4ERR_TOO_BIG_TO_CACHE error.
This code is set up to do a real DRC.

A replay with cachethis set to false returns a NFS4ERR_RETRY_UNCACHED_REP
error.

0004-nfs41-prepare-for-back-channel-drc.patch
0005-nfs41-back-channel-drc-minimal-implementation.patch

TODO: The callback code currently returns NFS4ERR_RESOURCE on all xdr
overflows. This is correct for v4.0, incorrect for v4.1.

Testing:

Modified nfsv4.1 pynfs server tested cb_recall replays with the cb_sequence
cachethis set to False and to True.

Connectathon tests pass.

-->Andy

