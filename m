Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:55546 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752207Ab1LYNyz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Dec 2011 08:54:55 -0500
Date: Sun, 25 Dec 2011 08:54:43 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>,
        fanchaoting <fanchaoting@cn.fujitsu.com>,
        Benny Halevy <benny@tonian.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fix do_xor_speed 64-bit devision issue on 32-bits arch
Message-ID: <20111225135443.GA19491@umich.edu>
References: <1323266927-3686-1-git-send-email-bhalevy@tonian.com>
 <4EF422A8.5070907@cn.fujitsu.com>
 <20111223132546.GA10015@umich.edu>
 <4EF6B516.5070609@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EF6B516.5070609@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny Halevy wrote:

  > speed = do_div(BENCH_SIZE, 1024) * count * do_div(NSEC_PER_SEC, ns_end);
  > 
  > This might not be exactly right because it changes the operator precedence,
  > but it should eliminate the calls to __udivdi3.
  
  Hmm, you mean execution order? (which you do not)
  C (and fortunately gcc too :) treats multiplication and division with the
  same priority and executes them from left to right...

Yes, execution order.  The original code executes left-to-right, my code
executes the divisions first.

But I wouldn't blindly apply this without understanding what's going on
here.  I thought the -fno-tree-scev-cprop compiler flag was supposed to
emit division code instead of calling into a library.
