Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.eperm.de ([89.247.134.16]:60166 "EHLO mail.eperm.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751861AbdFKVGT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 11 Jun 2017 17:06:19 -0400
From: Stephan =?ISO-8859-1?Q?M=FCller?= <smueller@chronox.de>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com,
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
        linux-nfs@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Subject: Re: [PATCH 0/6] Constant Time Memory Comparisons Are Important
Date: Sun, 11 Jun 2017 23:06:14 +0200
Message-ID: <20235732.W6WmnKk6cl@tauon.chronox.de>
In-Reply-To: <20170610025912.6499-1-Jason@zx2c4.com>
References: <20170610025912.6499-1-Jason@zx2c4.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Samstag, 10. Juni 2017, 04:59:06 CEST schrieb Jason A. Donenfeld:

Hi Jason,

> Whenever you're comparing two MACs, it's important to do this using
> crypto_memneq instead of memcmp. With memcmp, you leak timing information,
> which could then be used to iteratively forge a MAC. This is far too basic
> of a mistake for us to have so pervasively in the year 2017, so let's begin
> cleaning this stuff up. The following 6 locations were found with some
> simple regex greps, but I'm sure more lurk below the surface. If you
> maintain some code or know somebody who maintains some code that deals
> with MACs, tell them to double check which comparison function they're
> using.

Are you planning to send an update to your patch set? If yes, there is another 
one which should be converted too: crypto/rsa-pkcs1pad.c.

Otherwise, I will send a patch converting this one.

Thanks.

Ciao
Stephan
