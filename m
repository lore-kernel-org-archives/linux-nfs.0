Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49503 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753492Ab2KZPrg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 10:47:36 -0500
Date: Mon, 26 Nov 2012 10:47:35 -0500
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: fixes for 3.8
Message-ID: <20121126154735.GA11860@fieldses.org>
References: <1353940799-11763-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1353940799-11763-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 26, 2012 at 09:39:51AM -0500, J. Bruce Fields wrote:
> The following are some fixes I plan to queue up for 3.8, mostly problems
> found while looking at the v4 xdr code.

I also added corresponding tests to

	git://linux-nfs.org/~bfields/pynfs.git

--b.
