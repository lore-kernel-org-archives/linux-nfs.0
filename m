Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:35284 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729574AbeGYTa5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Jul 2018 15:30:57 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CA+55aFy2v3OW+mmSDF4MPWW673WsJEdQef3LChWg5k9=_k9ggg@mail.gmail.com>
References: <CA+55aFy2v3OW+mmSDF4MPWW673WsJEdQef3LChWg5k9=_k9ggg@mail.gmail.com> <7828.1532527332@warthog.procyon.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, kiran.modukuri@gmail.com,
        linux-cachefs@redhat.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [GIT PULL] fscache and cachefiles fixes
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 25 Jul 2018 19:18:05 +0100
Message-ID: <25183.1532542685@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Why do they have commit times literally *minutes* before your email to
> ask me to pull?

I split the first patch into two because it had two more-or-less independent
changes and it made it easier to describe them separately.

David
