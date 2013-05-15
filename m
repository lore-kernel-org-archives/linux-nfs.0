Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dcvr.yhbt.net ([64.71.152.64]:53361 "EHLO dcvr.yhbt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753854Ab3EOToH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 15:44:07 -0400
Date: Wed, 15 May 2013 19:44:05 +0000
From: Eric Wong <normalperson@yhbt.net>
To: Zach Brown <zab@redhat.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [RFC v0 1/4] vfs: add copy_range syscall and vfs entry point
Message-ID: <20130515194405.GA28720@dcvr.yhbt.net>
References: <1368566126-17610-1-git-send-email-zab@redhat.com>
 <1368566126-17610-2-git-send-email-zab@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368566126-17610-2-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Zach Brown <zab@redhat.com> wrote:
> This adds a syscall and vfs entry point for clone_range which offloads
> data copying between existing files.
> 
> The syscall is a thin wrapper around the vfs entry point.  Its arguments
> are inspired by sys_splice().

Why introduce a new syscall instead of extending sys_splice?

Perhaps adding a new SPLICE_F_COPYRANGE flag to avoid compatibility
problems with userspace which may expect ESPIPE when given two non-pipes
would be useful.

If the user doesn't need a out offset, then sendfile() should also be
able to transparently utilize COPY/CLONE_RANGE, too.
