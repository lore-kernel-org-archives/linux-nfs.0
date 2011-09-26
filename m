Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48597 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986Ab1IZWhW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 18:37:22 -0400
Date: Mon, 26 Sep 2011 18:37:22 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/25] nfsd4 state cleanup
Message-ID: <20110926223722.GB22140@fieldses.org>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 14, 2011 at 07:44:56AM -0400, J. Bruce Fields wrote:
> 	- I need to look again at doing a better job of distinguishing
> 	  the bad, expired, and stale cases for stateid's.

OK, and the following patches move to looking up stateid's per clientid,
and also improve those error returns.

--b.
