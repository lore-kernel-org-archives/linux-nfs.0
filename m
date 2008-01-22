From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: inotify and nfsd exported filesystem
Date: Tue, 22 Jan 2008 15:29:16 -0500
Message-ID: <20080122202916.GL24697@fieldses.org>
References: <120329353@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: devzero-S0/GAf8tV78@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60160 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbYAVU3R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2008 15:29:17 -0500
In-Reply-To: <120329353-S0/GAf8tV78@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 22, 2008 at 09:26:24PM +0100, devzero-S0/GAf8tV78@public.gmane.org wrote:
> hello !
> 
> it seems that accessing a file via knfsd exported filesystem doesn`t
> create an appropriate event with inotify-tools, i.e. i cannot "see"
> that this file has been accessed.

What do you mean by "accessing"--is it just reads that are missed?
Writes as well?  Other kinds of modications of the filesystem?

--b.

> no problems if acess that file on the same machine via userspace - but
> accessing from a remote box via nfs just fails.
> 
> can somebody confirm this issue?
> 
> is this by design or is this a bug?
