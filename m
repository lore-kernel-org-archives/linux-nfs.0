Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:56093 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752251AbaESP33 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2014 11:29:29 -0400
Date: Mon, 19 May 2014 11:29:19 -0400
From: Jim Rees <rees@umich.edu>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/8] nfs: clean up function decls in nfs_page.h
Message-ID: <20140519152919.GA9712@umich.edu>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com>
 <1400512508-7530-8-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1400512508-7530-8-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Weston Andros Adamson wrote:

  For consistency, remove argument names in function declarations

This conflicts with the style guide:

Chapter 6: Functions

In function prototypes, include parameter names with their data types.
Although this is not required by the C language, it is preferred in Linux
because it is a simple way to add valuable information for the reader.
