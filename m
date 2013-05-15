Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865Ab3EOUDK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 16:03:10 -0400
Date: Wed, 15 May 2013 13:03:07 -0700
From: Zach Brown <zab@redhat.com>
To: Eric Wong <normalperson@yhbt.net>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [RFC v0 1/4] vfs: add copy_range syscall and vfs entry point
Message-ID: <20130515200307.GD318@lenny.home.zabbo.net>
References: <1368566126-17610-1-git-send-email-zab@redhat.com>
 <1368566126-17610-2-git-send-email-zab@redhat.com>
 <20130515194405.GA28720@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130515194405.GA28720@dcvr.yhbt.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 15, 2013 at 07:44:05PM +0000, Eric Wong wrote:
> Why introduce a new syscall instead of extending sys_splice?

Personally, I think it's ugly to have different operations use the same
syscall just because their arguments match.

But that preference aside, sure, if the consensus is that we'd rather
use the splice() entry point then I can duck tape the pieces together to
make it work.

> If the user doesn't need a out offset, then sendfile() should also be
> able to transparently utilize COPY/CLONE_RANGE, too.

Perhaps, yeah.

- z
