From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] send actual expiration for svcgssd gss contexts
Date: Mon, 8 Dec 2008 18:28:49 -0500
Message-ID: <20081208232849.GA24083@fieldses.org>
References: <20081204233341.5951.62162.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33743 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753356AbYLHX2v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2008 18:28:51 -0500
In-Reply-To: <20081204233341.5951.62162.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 04, 2008 at 06:34:53PM -0500, Kevin Coffman wrote:
> These patches allow svcgssd to supply the correct timeout value for the cache
> entries associated with gss contexts.  The init cache values are changed from
> "never" to 60 seconds.

That sounds reasonable to me, thanks.

--b.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
