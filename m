Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:62134 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757412AbbBEOt6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 09:49:58 -0500
Received: by mail-vc0-f182.google.com with SMTP id kv19so2792139vcb.13
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 06:49:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150205140701.GA3941@infradead.org>
References: <1423000784-93180-1-git-send-email-trond.myklebust@primarydata.com>
	<1423000784-93180-2-git-send-email-trond.myklebust@primarydata.com>
	<20150205140701.GA3941@infradead.org>
Date: Thu, 5 Feb 2015 09:49:57 -0500
Message-ID: <CAHQdGtRtnTEf0UoLjLbwUAPncfEzg1W43oAZu2UyueychvJ0mQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFSv4.1: Ask for no delegation on OPEN if already
 holding one
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 5, 2015 at 9:07 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Feb 03, 2015 at 04:59:44PM -0500, Trond Myklebust wrote:
>> If we already hold a delegation, there should be no reason for the
>> server to issue it to us again. Unfortunately, there appear to be
>> servers out there that engage in this practice. While it is often
>> harmless to do so, there is one case where this creates a problem
>> and that is when the client is in the process of returning that
>> delegation.
>> This patch uses the NFSv4.1 NFS4_SHARE_WANT_NO_DELEG flag to inform
>> the server not to return a delegation in these cases.
>
> Shouldn't this be patch 1 as it's the actual bug fix that might need
> backporting?

I'm dropping it instead. It doesn't completely close the race left
open by the lack of clarity in the protocol, and so it is
counterproductive; it will leave sloppy server vendors thinking the
problem is solved when it isn't.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
