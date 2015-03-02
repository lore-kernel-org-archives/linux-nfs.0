Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:59228 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbbCBUrm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2015 15:47:42 -0500
Received: by mail-vc0-f176.google.com with SMTP id kv7so2350917vcb.7
        for <linux-nfs@vger.kernel.org>; Mon, 02 Mar 2015 12:47:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEYVSNeBzN8Ok=vmjxrMj-fhYQSL=ny4rqvx4r5TQNLyg@mail.gmail.com>
References: <CAN-5tyEYVSNeBzN8Ok=vmjxrMj-fhYQSL=ny4rqvx4r5TQNLyg@mail.gmail.com>
Date: Mon, 2 Mar 2015 15:47:41 -0500
Message-ID: <CAHQdGtQxR_VT+8g5oNLHcsBOKcWVG6j7c+A2rQBO7VkP9E6WPA@mail.gmail.com>
Subject: Re: buggy CLOSE in the "testing" branch
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On Mon, Mar 2, 2015 at 3:15 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Hi folks,
>
> I'm experiencing that CLOSE uses a delegation stateid instead of the
> open stateid which I think is what the spec says. Server replies with
> BAD_STATEID.
>
> Is this a bug or did I misread the spec? Thanks.
>

That would be a client bug. Do you have a reproducer?

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
