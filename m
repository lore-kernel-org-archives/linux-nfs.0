Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:47472 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674Ab1G1DTS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 23:19:18 -0400
Date: Wed, 27 Jul 2011 23:19:22 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v3 03/25] NFS41: Let layoutcommit handle multiple segments
Message-ID: <20110728031922.GA15579@merit.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
 <1311792048-12551-4-git-send-email-rees@umich.edu>
 <4E306F84.6030808@panasas.com>
 <1311798159.25645.32.camel@lade.trondhjem.org>
 <4E30762E.4000508@panasas.com>
 <20110727205804.GA13698@merit.edu>
 <4E307E6F.6090309@panasas.com>
 <20110727234041.GC14319@merit.edu>
 <4E30A957.7080804@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E30A957.7080804@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  Where did the other changes come from? Is there a Benny's branch that
  have them separated so I can have a look. I suspect I also need the one
  that encodes the last_byte_written.

I have pushed this series to the pnfs-88 branch in my repo:
git://citi.umich.edu/projects/linux-pnfs-blk.git
