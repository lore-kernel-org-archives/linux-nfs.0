Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34506 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754801Ab1ESBMQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 21:12:16 -0400
Date: Wed, 18 May 2011 21:12:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] NFSD: added FREE_STATEID operation
Message-ID: <20110519011215.GG26545@fieldses.org>
References: <1305575021-2841-1-git-send-email-bjschuma@netapp.com>
 <1305575021-2841-2-git-send-email-bjschuma@netapp.com>
 <20110518225609.GA26545@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110518225609.GA26545@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 18, 2011 at 06:56:09PM -0400, J. Bruce Fields wrote:
> Also I guess a client shouldn't be permitted to free a delegation that
> it still holds.  That means we'll always just return nfserr_locks for
> delegation stateid's.  I assume free_stateid is only useful in this case
> for the case where a server forcibly revokes part of the client's state
> and leaves some "stub" stateid's around in place of the revoked ones.

So I think what we really need to do here is this:

	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#SEQ4_STATUS_RECALLABLE_STATE_REVOKED

--b.
