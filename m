Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36877 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932826AbaDINld convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Apr 2014 09:41:33 -0400
Received: by mail-ig0-f169.google.com with SMTP id h18so7084571igc.4
        for <linux-nfs@vger.kernel.org>; Wed, 09 Apr 2014 06:41:32 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Subject: commit 1bc49d83c37c (nfsd4: fix nfs4err_resource in 4.1 case)
Date: Wed, 9 Apr 2014 09:41:28 -0400
Message-Id: <ED8FB66B-E2A5-4BD5-95DE-160C9717D9AB@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

I have a question about that patch.

According to RFC5661, NFS4ERR_REP_TOO_BIG/NFS4ERR_REP_TOO_BIG_TO_CACHE are only appropriate if "The reply to a Compound would exceed the channel's negotiated maximum response size.”.
Given that the callers of nfsd4_encode_fattr appear to all pass in ‘buffer’ and ‘buflen’ arguments that are limited to single page, doesn’t this mean that you can end up returning nfs4err_resource in cases where nfserr_rep_too_big/nfserr_rep_too_big_to_cache are simply not appropriate?

Either way, the NFS client will handle this badly. There is no recovery for NFS4ERR_RESOURCE. and we do not ever expect to hit NFSERR_REP_TOO_BIG/TOO_BIG_TO_CACHE. The latter two can presumably only be recovered by renegotiating the session and then retrying the request, which won’t work here...

Cheers
  Trond
_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

