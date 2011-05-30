Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30221 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048Ab1E3L6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 May 2011 07:58:21 -0400
Date: Mon, 30 May 2011 07:59:30 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Ruediger Meier <sweet_f_a@gmx.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: infinite getdents64 loop
Message-ID: <20110530075930.134c7541@corrin.poochiereds.net>
In-Reply-To: <201105301137.02061.sweet_f_a@gmx.de>
References: <201105281502.32719.sweet_f_a@gmx.de>
	<201105291855.04487.sweet_f_a@gmx.de>
	<1306688643.2386.24.camel@lade.trondhjem.org>
	<201105301137.02061.sweet_f_a@gmx.de>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 30 May 2011 11:37:01 +0200
Ruediger Meier <sweet_f_a@gmx.de> wrote:

> On Sunday 29 May 2011, Trond Myklebust wrote:
> > It's actually a problem with the underlying filesystem: it is
> > generating readdir 'offsets' that are not unique. In other words, if
> 
> Does this mean ext4 generally does not work with for nfs?
> 
> 

Does it help if you turn off the dir_index feature on the filesystem?
See the tune2fs(8) manpage for how to do that.

-- 
Jeff Layton <jlayton@redhat.com>
