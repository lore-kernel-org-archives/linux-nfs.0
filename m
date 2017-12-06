Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38926 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750989AbdLFMdv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 07:33:51 -0500
Date: Wed, 6 Dec 2017 12:33:44 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Joshua Watt <jpewhacker@gmail.com>
Cc: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org, David Howells <dhowells@redhat.com>
Subject: Re: [RFC v4 4/9] namespace: Add umount_end superblock operation
Message-ID: <20171206123344.GA9875@ZenIV.linux.org.uk>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
 <20171117174552.18722-5-JPEWhacker@gmail.com>
 <20171206121441.GA21978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171206121441.GA21978@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 06, 2017 at 12:14:41PM +0000, Al Viro wrote:
> On Fri, Nov 17, 2017 at 11:45:47AM -0600, Joshua Watt wrote:
> > The umount_end operation allows cleaning of state set by umount_begin in
> > the event the filesystem doesn't actually get unmounted.
> 
> The locking doesn't make any sense.  This thing can come at *any* moment -
> one process does this force-unmount of yours, another comes and accesses
> the damn thing just as you've decided that umount has failed and go
> to call that method.

Consider, BTW, the situation when another umount -f comes just as you've
dropped ->s_umount.  Now your ->umount_end() comes *after* ->umount_begin()
from the second call.
