Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:47113 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751878AbdFKVWB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 11 Jun 2017 17:22:01 -0400
MIME-Version: 1.0
In-Reply-To: <20235732.W6WmnKk6cl@tauon.chronox.de>
References: <20170610025912.6499-1-Jason@zx2c4.com> <20235732.W6WmnKk6cl@tauon.chronox.de>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Sun, 11 Jun 2017 23:21:55 +0200
Message-ID: <CAHmME9rgVXkRfxEhJDu+LmAG64PT=NsJH3se_0ffPPXF=a8q+g@mail.gmail.com>
Subject: Re: [PATCH 0/6] Constant Time Memory Comparisons Are Important
To: =?UTF-8?Q?Stephan_M=C3=BCller?= <smueller@chronox.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
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
        Netdev <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Stephan,

On Sun, Jun 11, 2017 at 11:06 PM, Stephan M=C3=BCller <smueller@chronox.de>=
 wrote:
> Are you planning to send an update to your patch set? If yes, there is an=
other
> one which should be converted too: crypto/rsa-pkcs1pad.c.

I just sent an update to this thread patching that, per your
suggestion. Since these issues are expected to be cherry picked by
their respective committer, I figure we can just pile on the patches
here, listing the 0/6 intro email as each patch's parent.

Jason
