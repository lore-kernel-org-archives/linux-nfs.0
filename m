Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:34125
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753875Ab1G0VFV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 17:05:21 -0400
Date: Wed, 27 Jul 2011 17:05:14 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Anand Avati <avati@gluster.com>
Cc: miklos@szeredi.hu, fuse-devel@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] fuse: permit O_DIRECT flag in open()
Message-ID: <20110727210514.GD9066@infradead.org>
References: <n>
 <1311764179-20326-1-git-send-email-avati@gluster.com>
 <1311764179-20326-2-git-send-email-avati@gluster.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311764179-20326-2-git-send-email-avati@gluster.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 27, 2011 at 03:56:19AM -0700, Anand Avati wrote:
> FUSE currently disallows O_DIRECT flag in open(). It is tricky dealing with
> setting/unsetting of O_DIRECT flag on an open file. There are applications
> (primarily VMs and databases) which open files with O_DIRECT flag. These
> applications do not work on FUSE due to this limitation.
> 
> The approach with this patch is to permit opens with O_DIRECT, but instead
> disable setting/unsetting of the O_DIRECT flag no matter how the file was
> opened. This limitation is for more practical than disallowing O_DIRECT
> altogether.

But it's also entirely incorrect.  Fix your userspace to have a proper
fallback if O_DIRECT opens fail.  It's a feature only supported by a few
filesystems, and very few operating systems.

