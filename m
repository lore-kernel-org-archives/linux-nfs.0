Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:54441 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755785Ab3EQQuq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 May 2013 12:50:46 -0400
Date: Fri, 17 May 2013 12:50:38 -0400
From: Jim Rees <rees@umich.edu>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Is the code stateid_generation_after()in legal C?
Message-ID: <20130517165038.GA7147@umich.edu>
References: <OFD54C462E.9A1446D0-ONC1257B6E.004D4190-C1257B6E.00507192@transmode.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OFD54C462E.9A1446D0-ONC1257B6E.004D4190-C1257B6E.00507192@transmode.se>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Joakim Tjernlund wrote:

  static bool stateid_generation_after(stateid_t *a, stateid_t *b)
  {
          return (s32)a->si_generation - (s32)b->si_generation > 0;
  }
  
  overflow is undefined for signed integers and gcc uses that nowadays.
  Not sure if that can affect the above code?

I guess the intent there is to account for stateid wraparound. But it's not
clear to me this is doing the right thing. I think C specifies overflow
behavior for unsigned but not signed. So shouldn't it be something more like
this?

    (s32)(a->si_generation - b->si_generation) > 0

Either way, this probably deserves a comment.
