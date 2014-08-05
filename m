Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37087 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377AbaHETIx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2014 15:08:53 -0400
Date: Tue, 5 Aug 2014 15:08:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 36/37] nfsd: remove the client_mutex and the
 nfs4_lock/unlock_state wrappers
Message-ID: <20140805190850.GT23341@fieldses.org>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
 <1406723258-8512-37-git-send-email-jlayton@primarydata.com>
 <20140801072025.63f145b6@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140801072025.63f145b6@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 01, 2014 at 07:20:25AM -0400, Jeff Layton wrote:
> I just noticed that the above patch neglects to remove the declarations
> of nfs4_lock/unlock_state from state.h. Bruce, let me know if you want me
> to resend. Otherwise, I'll assume that you can fix that up.

Done.  And merged everything up to here, thanks!

--b.
