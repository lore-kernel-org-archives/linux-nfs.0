Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:61191 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824Ab2KPWZ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Nov 2012 17:25:28 -0500
Date: Fri, 16 Nov 2012 17:25:22 -0500
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Reduce stack use in encode_exchange_id()
Message-ID: <20121116222522.GB12144@umich.edu>
References: <1353101475-11613-1-git-send-email-rees@umich.edu>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092E9FA3@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092E9FA3@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

  Hmm... Shouldn't we also be changing encode_exchange_id_maxsz to mirror
  this new buffer limit?

Probably. I'll fix it. Thanks.
