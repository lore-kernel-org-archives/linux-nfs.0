Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:58324 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab3LBHXL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 02:23:11 -0500
Message-ID: <529C355C.3000609@parallels.com>
Date: Mon, 2 Dec 2013 11:23:08 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>, <linux-nfs@vger.kernel.org>,
        <viro@zeniv.linux.org.uk>
CC: <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
References: <20131201131441.790963326@bombadil.infradead.org>
In-Reply-To: <20131201131441.790963326@bombadil.infradead.org>
Content-Type: text/plain; charset="windows-1251"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

01.12.2013 17:14, Christoph Hellwig пишет:
> As-is this has one major downside: because the initial mount already grabs
> a reference to the network namespace we'll create a cyclic reference and
> will never free the network namespace.  To get around this we'd need
> some way to only grab it once user mounts show up / disapear in the VFS.

That's a great cleanup of the whole PipeFS mount/umount logic. And it actually
moves code to the state it was (with  minor changes) before net namespace
changes.
But the reason for all this "damage" was exactly to remove this major downside
and do _not_ tie network namespace to mount point..
So, please, solve the problem before reverting all this notifiers and friends.

-- 
Best regards,
Stanislav Kinsbursky
