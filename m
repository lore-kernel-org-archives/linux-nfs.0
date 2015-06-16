Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:36360 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbFPMcG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2015 08:32:06 -0400
Received: by ykdr198 with SMTP id r198so11820162ykd.3
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 05:32:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1857695394.3971135.1434449335470.JavaMail.zimbra@desy.de>
References: <1857695394.3971135.1434449335470.JavaMail.zimbra@desy.de>
Date: Tue, 16 Jun 2015 08:32:04 -0400
Message-ID: <CAHQdGtRN39m1UDFMbMn+35Wp=1L9XZYJAgYpZ850qgypcGKjJg@mail.gmail.com>
Subject: Re: crash on read overflow
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tigran,

On Tue, Jun 16, 2015 at 6:08 AM, Mkrtchyan, Tigran
<tigran.mkrtchyan@desy.de> wrote:
>
>
> Hi Trond,
>
> with RHEL6 kernel we observe kernel panic if server reply
> more data than client requested. This is obviously fixed in
> RHEL7 and upstream. Unfortunately, kernel crashes so badly
> that I can't get any stacktrace. My guess is that
> commit 64bd577ea0021f5903505de061b3b7d8a785ee94 is the one
> which fixes the issue. Can you confirm?
>

That should help, but you also need to ensure that they have applied
commit bfeea1dc1c92 ("SUNRPC: Don't decode beyond the end of the RPC
reply message").

You might possibly also need commit 1537693ceaa8 ("SUNRPC: Clean up
xdr_set_iov()") and commit 76cacaabf15a ("SUNRPC: xdr_read_pages needs
to clear xdr->page_ptr.") since those are all dependencies for
bfeea1dc1c92.

Cheers
  Trond
