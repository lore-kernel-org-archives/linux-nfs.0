Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:42761 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163849AbdKRTkq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Nov 2017 14:40:46 -0500
MIME-Version: 1.0
In-Reply-To: <20171118184020.GA22603@fieldses.org>
References: <20171118184020.GA22603@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 18 Nov 2017 11:40:44 -0800
Message-ID: <CA+55aFwPHpD0Ehq8_VawfLCTXgMkbWE3fvdNc__ELmirh1rPVQ@mail.gmail.com>
Subject: Re: [PULL REQUEST] nfsd changes for 4.15
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 18, 2017 at 10:40 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Please pull nfsd changes for 4.15 from:

Hmm. This had a tracepoint conflict with the nfs client pull.

The resolution seems obvious and I did it, but I'd like people to
review the end result but particularly also their workflows, because I
don't think that conflict was reported anywhere and doesn't seem to
exist in next-20171115.

It certainly wasn't mentioned to me in either pull request.

Were the nfs client changes not in next?

Tssk.

                      Linus
