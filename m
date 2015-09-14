Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:41328 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755702AbbINQj4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 12:39:56 -0400
Date: Mon, 14 Sep 2015 17:39:54 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] fs: add fput_queue
Message-ID: <20150914163954.GT22011@ZenIV.linux.org.uk>
References: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
 <1442238355-8203-4-git-send-email-jeff.layton@primarydata.com>
 <20150914141539.GS22011@ZenIV.linux.org.uk>
 <20150914101918.3d9c9235@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150914101918.3d9c9235@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 14, 2015 at 10:19:18AM -0400, Jeff Layton wrote:
> > > + * borrow the infrastructure used by kthreads, and the task can then just
> > > + * called flush_delayed_fput to ensure that the final fput has completed.
> > 
> > Are you sure that it's not a typo?
> 
> I don't think so, but it could be clearer. Something like this maybe?
> 
>      "then we can't queue it via task_work_add."

Huh?

task_work_add() callbacks *will* run before we return to userland
