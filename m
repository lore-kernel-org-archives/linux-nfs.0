Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:64589 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932316AbbBDMco (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 07:32:44 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so3544851igb.5
        for <linux-nfs@vger.kernel.org>; Wed, 04 Feb 2015 04:32:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150204081624.GA16543@infradead.org>
References: <1423000784-93180-1-git-send-email-trond.myklebust@primarydata.com>
	<20150204081624.GA16543@infradead.org>
Date: Wed, 4 Feb 2015 07:32:43 -0500
Message-ID: <CAABAsM4Sy+252QAhwOk_6RM6rGq0g4AxtHA2Yp0dovKeN6At7A@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4.1: Ask for no delegation on OPEN if using O_DIRECT
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, Olga.Kornievskaia@netapp.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 4, 2015 at 3:16 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Feb 03, 2015 at 04:59:43PM -0500, Trond Myklebust wrote:
>> If we're using NFSv4.1, then we have the ability to let the server know
>> whether or not we believe that returning a delegation as part of our OPEN
>> request would be useful.
>> The feature needs to be used with care, since the client sending the request
>> doesn't necessarily know how other clients are using that file, and how
>> they may be affected by the delegation.
>> For this reason, our initial use of the feature will be to let the server
>> know when the client believes that handing out a delegation would not be
>> useful.
>> The first application for this function is when opening the file using
>> O_DIRECT.
>
> I can't see why O_DIRECT openers would not want to use a delegation, can you
> explain your rationale?
>

Delegations are all about allowing the NFS client to cache data
aggressively, and notifying when it is no longer safe to do so. That
is clearly not of interest to an application using O_DIRECT, since it
is by definition managing the data cache (if there is one) instead of
the NFS client. We don't share delegation state with userspace and
even if we did, there are no existing applications out there that are
capable (or even interested) of taking advantage of it.

You can argue that the client could still use the delegation to cache
metadata and open/lock state, but most of the users of O_DIRECT of
which I'm aware tend to be data intensive, and not very metadata/state
intensive. So why burden both the server and the with that extra state
management?

Cheers
  Trond
