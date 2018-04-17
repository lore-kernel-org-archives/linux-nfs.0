Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55502 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750741AbeDQPAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 11:00:44 -0400
Date: Tue, 17 Apr 2018 11:00:03 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Olga Kornievskaia <kolga@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180417150002.GF10291@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180417065203.GA15145@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 16, 2018 at 11:52:03PM -0700, Christoph Hellwig wrote:
> Also even if we have a good reason to add it I absolutely want a config
> option for the feature - it is a lot code adding potential attack
> vectors, so we should not just enabled it by default.

By the way, am I forgetting some mitigation or can a client provide any
address it wants as the source server to copy from?

That opens up the server to a lot of the same risks you'd see from
unprivileged NFS mounts--a malicious client could copy from a server
under it's control that's modified to exploit bugs in the server's NFS
client code.

I wonder if there's also the possibility of weird results even without
malicious intent: e.g. a user copying files between two different
servers may unintentionally tie up resources on the target server.

There's interest in enabling unprivileged NFS mounts to allow
unprivileged containers to do NFS mounts.  But even if we get to the
point where we're comfortable enabling that, distributions may still
want it off by default, and may advise admins to do firewalling that
restricts the set of NFS servers that containers can mount.

--b.
