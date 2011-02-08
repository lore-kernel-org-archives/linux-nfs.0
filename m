Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49293 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752646Ab1BHQI1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 11:08:27 -0500
Date: Tue, 8 Feb 2011 17:08:23 +0100
From: Karel Zak <kzak@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] mount: move generic functions to utils.c and
	network.c
Message-ID: <20110208160823.GA21408@nb.net.home>
References: <1297172717-26431-1-git-send-email-kzak@redhat.com> <1297172717-26431-2-git-send-email-kzak@redhat.com> <D42D29E5-82B4-4786-BB0C-D2672A58F522@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D42D29E5-82B4-4786-BB0C-D2672A58F522@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 08, 2011 at 10:43:23AM -0500, Chuck Lever wrote:
> Nice work, just a few nits so far.

I'll send updated version later. Thanks for your feedback.

> I'll wait for utils-linux
> 2.19... and we have NFS Connectathon (http://www.connectathon.org)
> in a couple of weeks, so it will be March before I can spend some
> quality time with this.
> 
> Also, I'm cleaning up a version of parse_opt.c and token.c for you,
> if you want to include these in libmount at some point.

The library already has some code for mount options parsing, but there
is not code to create a list from parsed mount options. The library 
already uses struct list_head (originally probably from e2fsprogs
and Linux kernel, see include/list.h in util-linux), so maybe we can
use it for mount options too.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
