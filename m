Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53640 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751725AbdFKINJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jun 2017 04:13:09 -0400
From: Kalle Valo <kvalo@codeaurora.org>
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
References: <20170610025912.6499-1-Jason@zx2c4.com>
Date: Sun, 11 Jun 2017 11:13:01 +0300
In-Reply-To: <20170610025912.6499-1-Jason@zx2c4.com> (Jason A. Donenfeld's
        message of "Sat, 10 Jun 2017 04:59:06 +0200")
Message-ID: <878tkzq6wi.fsf@purkki.adurom.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Jason A. Donenfeld" <Jason@zx2c4.com> writes:

> Whenever you're comparing two MACs, it's important to do this using
> crypto_memneq instead of memcmp. With memcmp, you leak timing information,
> which could then be used to iteratively forge a MAC.

Do you have any pointers where I could learn more about this?

-- 
Kalle Valo
