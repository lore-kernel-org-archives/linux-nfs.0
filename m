Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:49328 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291Ab1HYTtx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Aug 2011 15:49:53 -0400
Date: Thu, 25 Aug 2011 15:49:51 -0400
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Leonardo Borda <leonardoborda@gmail.com>
Subject: Re: [PATCH] nfsd4: permit read opens of executable-only files
Message-ID: <20110825194951.GD6562@merit.edu>
References: <20110825161957.GC1114@fieldses.org>
 <20110825173147.GA5286@merit.edu>
 <20110825185234.GE1114@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110825185234.GE1114@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:

  commit a9fd873383e3affa5ba7017713fa46949147d418
  Author: J. Bruce Fields <bfields@redhat.com>
  Date:   Thu Aug 25 14:23:39 2011 -0400
  
      nfsd: prettify NFSD_MAY_* flag definitions
      
      Cc: Jim Rees <rees@umich.edu>
      Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Acked-By: Jim Rees <rees@umich.edu>
