Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:55620 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617Ab1HYRbt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Aug 2011 13:31:49 -0400
Date: Thu, 25 Aug 2011 13:31:47 -0400
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Leonardo Borda <leonardoborda@gmail.com>
Subject: Re: [PATCH] nfsd4: permit read opens of executable-only files
Message-ID: <20110825173147.GA5286@merit.edu>
References: <20110825161957.GC1114@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110825161957.GC1114@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:

   #define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
   #define NFSD_MAY_NOT_BREAK_LEASE 512
   #define NFSD_MAY_BYPASS_GSS	1024
  +#define NFSD_MAY_READ_IF_EXEC	2048

Not the fault of your patch, but it seems odd, unreadable, and error-prone
that these flag bits are defined in terms of base-10 numbers.
