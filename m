Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45559 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754118Ab1J0Kye (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Oct 2011 06:54:34 -0400
Message-ID: <4EA93868.8070404@suse.cz>
Date: Thu, 27 Oct 2011 12:54:32 +0200
From: Michal Marek <mmarek@suse.cz>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH] fs/Makefile: Always inspect exofs/
References: <4EA5FAD7.4020806@panasas.com>
In-Reply-To: <4EA5FAD7.4020806@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 25.10.2011 01:55, Boaz Harrosh wrote:
> 
> fs/exofs directory has multiple targets now, of which the
> ore.ko will be needed by the pnfs-objects-layout-driver
> (fs/nfs/objlayout).
> 
> As suggested by: Michal Marek <mmarek@suse.cz>  convert
> inclusion of exofs/ from obj-$(CONFIG_EXOFS_FS) => obj-$(y).

I suggested obj-y verbatim, at least this is what I meant. obj-$(y)
expands to "obj-" and will do nothing.

Michal
