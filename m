Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36615 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdFKNg3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jun 2017 09:36:29 -0400
Received: by mail-io0-f177.google.com with SMTP id y77so46561093ioe.3
        for <linux-nfs@vger.kernel.org>; Sun, 11 Jun 2017 06:36:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <878tkzq6wi.fsf@purkki.adurom.net>
References: <20170610025912.6499-1-Jason@zx2c4.com> <878tkzq6wi.fsf@purkki.adurom.net>
From: Kees Cook <keescook@chromium.org>
Date: Sun, 11 Jun 2017 06:36:27 -0700
Message-ID: <CAGXu5jKp=X7-eKo+HgzS3uqncx5yy-u=tJNqV9K8GOgJ=-C7iA@mail.gmail.com>
Subject: Re: [PATCH 0/6] Constant Time Memory Comparisons Are Important
To: Kalle Valo <kvalo@codeaurora.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        David Howells <dhowells@redhat.com>,
        David Safford <safford@us.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Gilad Ben-Yossef <gilad@benyossef.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        keyrings@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 11, 2017 at 1:13 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
> "Jason A. Donenfeld" <Jason@zx2c4.com> writes:
>
>> Whenever you're comparing two MACs, it's important to do this using
>> crypto_memneq instead of memcmp. With memcmp, you leak timing information,
>> which could then be used to iteratively forge a MAC.
>
> Do you have any pointers where I could learn more about this?

While not using C specifically, this talks about the problem generally:
https://www.chosenplaintext.ca/articles/beginners-guide-constant-time-cryptography.html

-Kees

-- 
Kees Cook
Pixel Security
