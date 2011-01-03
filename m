Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57213 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755529Ab1ACUMB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 15:12:01 -0500
Date: Mon, 3 Jan 2011 15:12:00 -0500
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd cache_check fix and change to nfserr_dropit handling
Message-ID: <20110103201200.GA18056@fieldses.org>
References: <1294079454-17891-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294079454-17891-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 03, 2011 at 01:30:49PM -0500, J. Bruce Fields wrote:
> A little more bugfixing and cleanup to be queued up for 2.6.38 if nobody
> sees a problem with it.

My fingers seem to have decided that no matter what I'm working on, it
must start with "nfsd4:".  Sorry about that; fixing up the subject
lines....

--b.

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
