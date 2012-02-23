Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44012 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753268Ab2BWBBN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Feb 2012 20:01:13 -0500
Date: Wed, 22 Feb 2012 20:01:11 -0500
To: Peter Horvath <peter.horvath77@googlemail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 client restriction
Message-ID: <20120223010111.GA19432@fieldses.org>
References: <CAO9xhuZ+2VsTog1bqomC82jVfNFVOx6JTGgG+muDQsFu_5R7ZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAO9xhuZ+2VsTog1bqomC82jVfNFVOx6JTGgG+muDQsFu_5R7ZA@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 22, 2012 at 07:24:12PM +0000, Peter Horvath wrote:
> We are using Ubuntu LTS 10.04 servers and clients.
> NFS version is the following:
> nfs-common                     1.2.0-4ubuntu4.2
> nfs-kernel-server               1.2.0-4ubuntu4.2
> 
> My exports looks like this:
> 
> /srv 10.66.3.0/24(fsid=0,ro,no_subtree_check,sync)
> /srv/www/project1 10.66.3.101(rw,no_root_squash,no_subtree_check,sync)
> /srv/www/project2 10.66.3.102(rw,no_root_squash,no_subtree_check,sync)
> /srv/www/project3 10.66.3.103(rw,no_root_squash,no_subtree_check,sync)
> 
> My problem is that in this case clients have only read-only access. If
> i set the pseudofilesystem root to RW it is working but in that case
> all the clients would be able to mount the root and access other
> projects too.
> How can i achieve the same results as it was in NFSv3 with this config.
> 
> /srv/www/project1 10.66.3.101(rw,no_root_squash,no_subtree_check,sync)
> /srv/www/project2 10.66.3.102(rw,no_root_squash,no_subtree_check,sync)
> /srv/www/project3 10.66.3.103(rw,no_root_squash,no_subtree_check,sync)

Are project1, 2, 3 on the same filesystem as /srv and /srv/www?

If so, this is expected; create a separate partition for /srv/www, or
for each project1, 2, 3 directory, and you may find the problem is
fixed.

If that doesn't fix the problem, it may be a bug.  We've fixed a few
bugs in that area lately, so it would be worth retrying with more recent
kernel and nfs-utils.

--b.
