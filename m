Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:56979 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743Ab3ERO6q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 May 2013 10:58:46 -0400
Date: Sat, 18 May 2013 10:58:08 -0400
From: Jim Rees <rees@umich.edu>
To: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: avoid undefined signed overflow
Message-ID: <20130518145808.GA3670@umich.edu>
References: <1368826380-9864-1-git-send-email-rees@umich.edu>
 <1368875049.11003.31.camel@thorin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368875049.11003.31.camel@thorin>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bernd Petrovitsch wrote:

  Hmm, what is actually wrong with plain-old
  ----  snip  ----
  static bool stateid_generation_after(stateid_t *a, stateid_t *b)
  {
  	return a->si_generation > b->si_generation;
  }
  ----  snip  ----
  ?

It doesn't account for wraparound. Try this:

    unsigned int a = 0xffff0000, b = 0x7fff0000;
    printf("%d %d\n", a > b, (int)(a - b) > 0);

I just realized that I said this needed a comment, then didn't provide one.
