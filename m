Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38488 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752297AbdLFMOw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 07:14:52 -0500
Date: Wed, 6 Dec 2017 12:14:41 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Joshua Watt <jpewhacker@gmail.com>
Cc: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org, David Howells <dhowells@redhat.com>
Subject: Re: [RFC v4 4/9] namespace: Add umount_end superblock operation
Message-ID: <20171206121441.GA21978@ZenIV.linux.org.uk>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
 <20171117174552.18722-5-JPEWhacker@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171117174552.18722-5-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 17, 2017 at 11:45:47AM -0600, Joshua Watt wrote:
> The umount_end operation allows cleaning of state set by umount_begin in
> the event the filesystem doesn't actually get unmounted.

The locking doesn't make any sense.  This thing can come at *any* moment -
one process does this force-unmount of yours, another comes and accesses
the damn thing just as you've decided that umount has failed and go
to call that method.

In other words, filesystem can be accessed before and during that call.
And that is not to mention the fact that in another namespace the same
super_block might remain mounted through all of that, giving overlapping
accesses during and after ->umount_begin(), so the latter can't do
anything other than "try and kill those waiting on that fs" anyway.
