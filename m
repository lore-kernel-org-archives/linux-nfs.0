Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:50046 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932838Ab0JXPfH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Oct 2010 11:35:07 -0400
Date: Sun, 24 Oct 2010 11:35:03 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] move include lines out of include file
Message-ID: <20101024153503.GC10769@merit.edu>
References: <20101022005120.GA15788@merit.edu>
 <4CC4203C.2050600@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CC4203C.2050600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  This patch does *not* break the header's independence. .i.e the header can
  still be compiled independently without any other includes. Which means
  some of the includes here are un-needed.

Thanks!  I tried removing all the includes but was too lazy to figure out
which one was really needed by simple_rpc_pipefs.c.
