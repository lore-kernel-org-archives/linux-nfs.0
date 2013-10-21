Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:35016 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444Ab3JURKU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 13:10:20 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 0/5] Clean up open CLAIM_PREVIOUS code path
Date: Mon, 21 Oct 2013 13:10:09 -0400
Message-ID: <1382375414-5854-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My original patch was to just fix the NULL dereference, but Trond noticed
some other problems in _nfs4_opendata_reclaim_to_nfs4_state, so I went ahead
and fixed them.

I separated this into multiple patches for increased bisectability and made
sure the NULL dereference patch was first so that stable@ / distros can choose
to just fix the crash if they wish. 

I went a bit further than the issues Trond raised with the last patch, but I
think it's good for consistency and catching reference counting bugs as errors
and not BUG()s.

 -dros

Weston Andros Adamson (5):
  NFSv4: fix NULL dereference in open recover
  NFSv4: don't fail on missing fattr in open recover
  NFSv4: clean up state ref counting in open recover
  NFSv4: don't reprocess cached open CLAIM_PREVIOUS
  NFSv4: clean up nfs4_state reference counting

 fs/nfs/nfs4proc.c  | 39 +++++++++++++++++++++++++--------------
 fs/nfs/nfs4state.c |  3 ++-
 2 files changed, 27 insertions(+), 15 deletions(-)

-- 
1.7.12.4 (Apple Git-37)

