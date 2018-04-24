Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48496 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750756AbeDXWQM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Apr 2018 18:16:12 -0400
Date: Tue, 24 Apr 2018 18:16:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Args need to be the same for replay cache
Message-ID: <20180424221612.GA30120@fieldses.org>
References: <1507740502-5151-1-git-send-email-Thomas.Haynes@primarydata.com>
 <20180410194922.GD5652@fieldses.org>
 <CAN-5tyFZDJcQPyHyBjeS0BDS-dqe6iS1+k9jftxDqnDMy__D5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyFZDJcQPyHyBjeS0BDS-dqe6iS1+k9jftxDqnDMy__D5g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 24, 2018 at 04:10:29PM -0400, Olga Kornievskaia wrote:
> Do you by any chance have a reference to this discussion?

This:
	http://lkml.kernel.org/r/1507740502-5151-1-git-send-email-Thomas.Haynes@primarydata.com

and this:

	http://lkml.kernel.org/r/E0161195-9F4A-4B36-A71D-6A924498C893@primarydata.com

and followups.

> I would like to reference it. For now I'm hijacking this thread to
> bring this up. I'm still concerned about the case where client sent a
> request and slot got interrupted (so by default the client doesn't
> increment the seq#). Then the client re-used the slot for the same
> kind of operation (WRITE is very interesting) with same arguments but
> say different FH. Is the server obligated the cache the whole call to
> address and check that? You have a patch to check for false retries
> that checks for different creds but I don't think you have something
> that would catch this case?

Right.  I don't believe the spec requires us to catch false retries in
every possible case.  That may mean we return a pretty bizarre reply
that doesn't match the request, but that's the client's own fault....

--b.
