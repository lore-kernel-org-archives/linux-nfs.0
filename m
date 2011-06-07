Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43992 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753982Ab1FGXDL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 19:03:11 -0400
Date: Tue, 7 Jun 2011 19:03:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Shilovsky <piastryyy@gmail.com>
Cc: linux-nfs@vger.kernel.org, Sean Finney <sean.finney@sonyericsson.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: Regression in current master
Message-ID: <20110607230311.GE13911@fieldses.org>
References: <BANLkTinFR06gifZxx9f8Go2ngjm6TYNayw@mail.gmail.com>
 <20110607230107.GD13911@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110607230107.GD13911@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 07, 2011 at 07:01:07PM -0400, J. Bruce Fields wrote:
> On Wed, Jun 01, 2011 at 11:43:47AM +0400, Pavel Shilovsky wrote:
> > Commit 9274e94db85bac04e170414cb8e0f4be271cde90
> > (http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=9274e94db85bac04e170414cb8e0f4be271cde90)
> > caused the regression when --manage-gids option is enabled: a user
> > doesn't get group list through getgrouplist when auth_unix_gid is
> > called twice. When I remove static attributes from gid_t *groups and
> > int groups_len, it works good.
> 
> Looking at the patch....
> 
> Hm, I can't spot the bug.  Sean?

Whoops, sorry, missed your later message!

--b.

> 
> (Also, not a correctness issue, but: shouldn't
> 
> 	if (rv == -1 && ngroups >= groups_len) {
> 
> be
> 
> 	if (rv == -1 && ngroups > groups_len) {
> 
> ?
> 
> And, finally, why do we need the separate groups_len == 0 case at the
> start at all?  The realloc case should be able to handle the initial
> case as well.
> 
> )
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
