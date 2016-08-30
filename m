Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34414 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753924AbcH3SXh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2016 14:23:37 -0400
MIME-Version: 1.0
In-Reply-To: <1472557703-5985-1-git-send-email-jlayton@redhat.com>
References: <1472557703-5985-1-git-send-email-jlayton@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 30 Aug 2016 11:23:36 -0700
Message-ID: <CA+55aFzVnBqtk5Az3VNMQ=HfTUBSYyOVejHykU2c63K70s24=A@mail.gmail.com>
Subject: Re: [PATCH] nfsd: more robust allocation failure handling in nfsd_reply_cache_init
To: Jeff Layton <jlayton@redhat.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Olaf Hering <olaf@aepfle.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 30, 2016 at 4:48 AM, Jeff Layton <jlayton@redhat.com> wrote:
>
> While this would be good to get in, I don't see any particular urgency
> here. This seems like it'd be reasonable for v4.9.

Agreed, looks ok to me. It certainly does not look like a new
regression or like a serious problem issue in practice. So 4.9 sounds
appropriate.

            Linus
