Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:52679 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751666AbdFJC7W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Jun 2017 22:59:22 -0400
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
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
Subject: [PATCH 0/6] Constant Time Memory Comparisons Are Important
Date: Sat, 10 Jun 2017 04:59:06 +0200
Message-Id: <20170610025912.6499-1-Jason@zx2c4.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Whenever you're comparing two MACs, it's important to do this using
crypto_memneq instead of memcmp. With memcmp, you leak timing information,
which could then be used to iteratively forge a MAC. This is far too basic
of a mistake for us to have so pervasively in the year 2017, so let's begin
cleaning this stuff up. The following 6 locations were found with some
simple regex greps, but I'm sure more lurk below the surface. If you
maintain some code or know somebody who maintains some code that deals
with MACs, tell them to double check which comparison function they're
using.

Jason A. Donenfeld (6):
  sunrpc: use constant time memory comparison for mac
  net/ipv6: use constant time memory comparison for mac
  ccree: use constant time memory comparison for macs and tags
  security/keys: use constant time memory comparison for macs
  bluetooth/smp: use constant time memory comparison for secret values
  mac80211/wpa: use constant time memory comparison for MACs

Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: David Howells <dhowells@redhat.com>
Cc: David Safford <safford@us.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: keyrings@vger.kernel.org
Cc: linux-bluetooth@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org

 drivers/staging/ccree/ssi_fips_ll.c   | 17 ++++++++-------
 net/bluetooth/smp.c                   | 39 ++++++++++++++++++-----------------
 net/ipv6/seg6_hmac.c                  |  3 ++-
 net/mac80211/wpa.c                    |  9 ++++----
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  3 ++-
 security/keys/trusted.c               |  7 ++++---
 6 files changed, 42 insertions(+), 36 deletions(-)

-- 
2.13.1
