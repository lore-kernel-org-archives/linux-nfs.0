Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39780 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbbINOPm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 10:15:42 -0400
Date: Mon, 14 Sep 2015 15:15:39 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] fs: add fput_queue
Message-ID: <20150914141539.GS22011@ZenIV.linux.org.uk>
References: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
 <1442238355-8203-4-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1442238355-8203-4-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 14, 2015 at 09:45:54AM -0400, Jeff Layton wrote:
> +/**
> + * fput_queue - do an fput without using task_work
> + * @file: file of which to put the reference
> + *
> + * If we need to ensure that the final __fput is done on a file before
> + * returning to userland, then we can't queue it to task_work. For that we
                                                       ?????????
> + * borrow the infrastructure used by kthreads, and the task can then just
> + * called flush_delayed_fput to ensure that the final fput has completed.

Are you sure that it's not a typo?
