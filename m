Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52954 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751981AbdHAVoU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Aug 2017 17:44:20 -0400
Date: Tue, 1 Aug 2017 17:44:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: delegation self-conflicts
Message-ID: <20170801214419.GJ21491@fieldses.org>
References: <20170721214547.GD21235@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170721214547.GD21235@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 21, 2017 at 05:45:47PM -0400, bfields wrote:
> I finally got around to looking at the delegation self-conflict problem
> you asked me about: it looks not hard at all to make the server stop
> revoking delegation in cases it's the client modifiying the file (or
> metatadata), as long as we're in the 4.1 case or otherwise know which
> client we're dealing with.  I should post patches next week.

Hah.  My first attempt didn't work, so it took longer than expected.
The second attempt looks good, but needs some testing.  That'll have to
wait a couple weeks--I'm going to be mostly offline for a while.

--b.

> 
> Remind me how you expect to take advantage of this?  I think you wanted
> to eliminate some cases where the client has to preemptively return
> delegations, but don't you then need some way to know ahead of time what
> the server behavior is?
> 
> --b.
