Return-Path: <SRS0=2Ld2=NY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59B2CC43441
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Nov 2018 21:06:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 086C3223AE
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Nov 2018 21:06:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 086C3223AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725750AbeKNHGc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 14 Nov 2018 02:06:32 -0500
Received: from fieldses.org ([173.255.197.46]:47224 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725748AbeKNHGc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Nov 2018 02:06:32 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id CE5932016; Tue, 13 Nov 2018 16:06:35 -0500 (EST)
Date:   Tue, 13 Nov 2018 16:06:35 -0500
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes
Message-ID: <20181113210635.GA23676@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please pull:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.20-1

Three nfsd bugfixes.  None are new bugs, but they all take a little
effort to hit, which might explain why they weren't found sooner.

--b.

Frank Sorenson (1):
      sunrpc: correct the computation for page_ptr when truncating

Scott Mayhew (1):
      nfsd: COPY and CLONE operations require the saved filehandle to be set

YueHaibing (1):
      SUNRPC: drop pointless static qualifier in xdr_get_next_encode_buffer()

 fs/nfsd/nfs4proc.c | 3 +++
 net/sunrpc/xdr.c   | 7 +++----
 2 files changed, 6 insertions(+), 4 deletions(-)
