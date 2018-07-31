Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:57468 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731007AbeGaX6h (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2018 19:58:37 -0400
Date: Tue, 31 Jul 2018 23:16:05 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Mark Fasheh <mfasheh@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] nfs: check for NULL vfsmount in nfs_getattr
Message-ID: <20180731221605.GK30522@ZenIV.linux.org.uk>
References: <20180731211045.5671-1-mfasheh@suse.de>
 <20180731211045.5671-3-mfasheh@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180731211045.5671-3-mfasheh@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 31, 2018 at 02:10:43PM -0700, Mark Fasheh wrote:
> ->getattr from inside the kernel won't always have a vfsmount, check for
> this.

Really?  Where would that happen?
