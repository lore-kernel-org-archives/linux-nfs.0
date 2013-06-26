Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50124 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912Ab3FZT1K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 15:27:10 -0400
Date: Wed, 26 Jun 2013 15:27:10 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] miscellaneous nfsd bugfixes
Message-ID: <20130626192710.GA4825@fieldses.org>
References: <1372274488-4752-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1372274488-4752-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 26, 2013 at 03:21:20PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> These are fixes for some miscellaneous bugs found at the bakeathon, to
> be queued for 3.11.

Also to help track down the decoding errors I added a dumb pynfs test,
WRITE15, which does writes of every possible size from 0 bytes to 8k:

	git://linux-nfs.org/~bfields/pynfs.git

--b.
