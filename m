Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44772 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754311Ab1JQV5l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:57:41 -0400
Date: Mon, 17 Oct 2011 17:57:41 -0400
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: fix for open leaks, for 3.2
Message-ID: <20111017215741.GE13368@fieldses.org>
References: <1318888557-14719-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1318888557-14719-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 17, 2011 at 05:55:49PM -0400, J. Bruce Fields wrote:
> Bryan Schumaker noticed that we have a longstanding leak of an open
> owner each time the first open with a new open owner fails.
> 
> The following patches fix that, along with a few other less likely leaks
> that occur if a memory allocation fails after a file is created.

By the way, Bryan, I didn't try to write a real test case for that
leak--would it be easy for you to rerun the test you were running before
and verify whether it's gone?

--b.

> 
> I intend to commit these to for-3.2.  Any review welcomed.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
