Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:45556 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752211AbdLFPmG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 10:42:06 -0500
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <1512574862.448.24.camel@gmail.com>
Subject: Re: [RFC v4 4/9] namespace: Add umount_end superblock operation
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org
In-Reply-To: <20171206123344.GA9875@ZenIV.linux.org.uk>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
         <20171117174552.18722-5-JPEWhacker@gmail.com>
         <20171206121441.GA21978@ZenIV.linux.org.uk>
         <20171206123344.GA9875@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Dec 2017 09:41:02 -0600
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-12-06 at 12:33 +0000, Al Viro wrote:
> On Wed, Dec 06, 2017 at 12:14:41PM +0000, Al Viro wrote:
> > On Fri, Nov 17, 2017 at 11:45:47AM -0600, Joshua Watt wrote:
> > > The umount_end operation allows cleaning of state set by
> > > umount_begin in
> > > the event the filesystem doesn't actually get unmounted.
> > 
> > The locking doesn't make any sense.  This thing can come at *any*
> > moment -
> > one process does this force-unmount of yours, another comes and
> > accesses
> > the damn thing just as you've decided that umount has failed and go
> > to call that method.
> 
> Consider, BTW, the situation when another umount -f comes just as
> you've
> dropped ->s_umount.  Now your ->umount_end() comes *after*
> ->umount_begin()
> from the second call.

Yes I realised that was a posibility, which is why the NFS
implementation of this uses an atomic counter in ->umount_begin() and 
->umount_end(). My line of thinking was that most fs drivers are
probably going to ignore ->umount_end(), so it is only those that
implement it that need to actually account for that problem.

Or rather put, we can punt that problem to the FS driver writers if
they choose to implement ->umount_end(). Maybe that isn't fair to the
fs driver writers? Or maybe it just needs better documentation of that
expectation?

cc'ing linux-fsdevel@vger.kernel.org, original message chain can be
found here:
http://www.spinics.net/lists/linux-nfs/msg66483.html

Thanks,
Joshua Watt

