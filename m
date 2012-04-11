Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43733 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760003Ab2DKQFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 12:05:25 -0400
Date: Wed, 11 Apr 2012 12:05:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 0/8] NFSd: precursor and cleanup patch set
Message-ID: <20120411160523.GA28928@fieldses.org>
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2012 at 07:08:53PM +0400, Stanislav Kinsbursky wrote:
> This patch set prepares ground for making NFSd export and expkey caches
> allocated and registered per network namespace context.
> Mainly, it just replaces hard-coded pointers with dereferenced everywhere
> required.
> 
> The following series consists of:

OK, thanks, applying these all pending some testing.  I'll try to get a
for-3.5 branch with this pushed out later today or tomorrow.

--b.
