From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patches] nfsd-affecting part of vfs queue
Date: Wed, 22 Apr 2009 17:34:15 -0400
Message-ID: <20090422213415.GJ9541@fieldses.org>
References: <E1LwNkj-0004WL-AW@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:39361 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335AbZDVVeQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 17:34:16 -0400
In-Reply-To: <E1LwNkj-0004WL-AW@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 21, 2009 at 09:43:41PM +0000, Al Viro wrote:
> 
> Fix for out-order dput() vs. mntput() (in nfsd_cross_mnt()) plus
> several "switch to passing struct path *" ones.  Comments would
> be welcome...
> 
> Entire queue is on git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/
> in "untested".

I haven't tested them, but otherwise they look like fine.  Shall queue
them in the nfsd tree?

--b.
