Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:48270 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754966Ab1K2Rsm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 12:48:42 -0500
Date: Tue, 29 Nov 2011 12:48:30 -0500
From: Jim Rees <rees@umich.edu>
To: Peng Tao <bergwolf@gmail.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, bhalevy@tonian.com,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH-RESEND 4/4] pnfsblock: do not ask for layout in pg_init
Message-ID: <20111129174830.GA3001@umich.edu>
References: <1322888194-3039-1-git-send-email-bergwolf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1322888194-3039-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peng Tao wrote:

  Asking for layout in pg_init will always make client ask for only 4KB
  layout in every layoutget. This way, client drops the IO size information
  that is meaningful for MDS in handing out layout.
  
  In stead, if layout is not find in cache, do not send layoutget
  at once. Wait until before issuing IO in pnfs_do_multiple_reads/writes
  because that is where we know the real size of current IO. By telling the
  real IO size to MDS, MDS will have a better chance to give proper layout.
  
  Signed-off-by: Peng Tao <peng_tao@emc.com>
  ---
  Resend to fix patch title. Sorry for the noise...

You may want to fix the patch date too, on this series and the other series
you sent earlier (later?).  I know China is in a later timezone but I don't
think it's that much later.
