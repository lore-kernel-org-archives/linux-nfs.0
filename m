Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36246 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbbJGXRm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 19:17:42 -0400
Received: by oibi136 with SMTP id i136so18080776oib.3
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 16:17:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151007200831.GB27924@fieldses.org>
References: <1444240482-11287-1-git-send-email-trond.myklebust@primarydata.com>
	<20151007200831.GB27924@fieldses.org>
Date: Wed, 7 Oct 2015 19:17:41 -0400
Message-ID: <CAHQdGtQT8+LeKyPghb9Ypr0kyF4aNXSOHCNDc3fvhZETvrpxLg@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Use MSG_SENDPAGE_NOTLAST when calling sendpage()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 7, 2015 at 4:08 PM, Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Oct 07, 2015 at 01:54:42PM -0400, Trond Myklebust wrote:
>> If we're sending more pages via kernel_sendpage(), then set
>> MSG_SENDPAGE_NOTLAST.
>
> Given that we've survived without this a while, I assume this is a hint
> that may provide better performance in some cases (have you seen that?)
> and that it doesn't have to be 100% correct?

See the original motivation in:

commit 2f5338442425 ("tcp: allow splice() to build full TSO packets")

and the later bugfix (which actually introduces MSG_SENDPAGE_NOTLAST):

commit 35f9c09fe9c7 ("tcp: tcp_sendpages() should call tcp_push() once")

> In which case, looks fine, will queue up for 4.4....

Sure. It's a minor performance enhancement, so there is no immediate rush.
