Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EF2CC4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 15:37:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5CEA42082E
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 15:37:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727039AbfDDPhk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Apr 2019 11:37:40 -0400
Received: from fieldses.org ([173.255.197.46]:59210 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726269AbfDDPhk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Apr 2019 11:37:40 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 4F7711E3A; Thu,  4 Apr 2019 11:37:40 -0400 (EDT)
Date:   Thu, 4 Apr 2019 11:37:40 -0400
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Jeff Layton <jlayton@poochiereds.net>
Cc:     "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: directory delegations
Message-ID: <20190404153740.GB24021@fieldses.org>
References: <20190402161116.GA2828@fieldses.org>
 <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
 <20190402194148.GA5269@fieldses.org>
 <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
 <20190403002822.GA7667@fieldses.org>
 <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
 <20190403020750.GA8272@fieldses.org>
 <c538dd35-fd1f-bab6-1cd3-6c9639462eab@oracle.com>
 <20190404010559.GA17840@fieldses.org>
 <CAOhYWNLZ2OmnGo2nEegmuXOrU_ncmAwWgQSAMXxKfn3JP-UMUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOhYWNLZ2OmnGo2nEegmuXOrU_ncmAwWgQSAMXxKfn3JP-UMUw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 04, 2019 at 11:09:47AM -0400, Jeff Layton wrote:
> On Wed, Apr 3, 2019 at 9:06 PM bfields@fieldses.org <bfields@fieldses.org> wrote:
> The serialized create with something like an untar is a
> performance-killer though.

Yes.  And Trond's proposal only allows hiding the server-to-disk round
trip time, not the client-to-server round trip time.  On the other hand,
it seems a lot easier than write delegations.

> FWIW, I'm working on something similar right now for Ceph. If a ceph
> client has adequate caps [1] for a directory and the dentry inode,
> then we should (in principle) be able to buffer up directory morphing
> operations and flush them out to the server asynchronously.
> 
> I'm starting with unlink (mostly because it's simpler), and am mainly
> just returning early when we do have the right caps -- after issuing
> the call but before the reply comes in. We should be able to do the
> same for link, rename and create too. Create will require the Ceph MDS
> to delegate out a range of inode numbers (and that bit hasn't been
> implemented yet).

Is there some reason it's impossible for the client to return from
create before it has an inode number?

> My thinking with all of this is that the buffering of directory
> morphing operations is not as helpful as something like a pagecache
> write is, as we aren't that interested in merging operations that
> change the same dentry. However, being able to do them asynchronously
> should work really well. That should allow us to better parallellize
> create/link/unlink/rename on different dentries even when they are
> issued serially by a single task.
> 
> RFC5661 doesn't currently provide for writeable directory delegations,
> AFAICT, but they could eventually be implemented in a similar way.

People also worried about delegating create in the face of differing
rules about case insensitivity and about which characters are legal in
filenames.  But I really think there should be some way to manage that.

--b.
