Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:51036 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697Ab1HYTsb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Aug 2011 15:48:31 -0400
Date: Thu, 25 Aug 2011 15:48:29 -0400
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Leonardo Borda <leonardoborda@gmail.com>
Subject: Re: [PATCH] nfsd4: permit read opens of executable-only files
Message-ID: <20110825194829.GC6562@merit.edu>
References: <20110825161957.GC1114@fieldses.org>
 <20110825173147.GA5286@merit.edu>
 <20110825185234.GE1114@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110825185234.GE1114@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:

  Odd is the one thing it isn't.
  
  I guess 1 << n would be easier but hex makes the mask line up nicer.
  So there.  ?

I glanced through include/linux and there doesn't seem to be any one
standard.  In fs.h you can find hex, decimal, and 1 << n all mixed together.
The fs-independent mount flags start out using decimal then switch to 1 << n
at 32768.
