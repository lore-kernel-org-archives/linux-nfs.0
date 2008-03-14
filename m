From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: theoretical rpcsec_gss deadlock
Date: Fri, 14 Mar 2008 14:23:20 -0400
Message-ID: <4d569c330803141123o23a35f4bm99ea9ca97a26c59d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-crypto@vger.kernel.org, linux-nfs@vger.kernel.org
To: "Herbert Xu" <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:23652 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbYCNSXW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:23:22 -0400
Received: by rn-out-0910.google.com with SMTP id v46so2866113rnb.15
        for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2008 11:23:20 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpcsec_gss code used for NFS currently does basically the
following to create a checksum for each rpc:

  crypto_alloc_hash()
  crypto_hash_init()
  crypto_hash_update() ...
  crypto_hash_final()
  crypto_free_hash()

The crypto_alloc_hash() poses a possible deadlock situation.
(Although it hasn't been a problem so far in practice.)  It would be
preferable to allocate the transform once in a context (shared by
multiple tasks).  However, doing so seems to cause problems with bad
checksums.  We'd rather not have to add a spinlock to serialize its
use.  Is there a way to allocate state information on the stack (or
elsewhere) such that the transform can be shared simultaneously?

Herbert, Bruce Fields says you suggested a while back that an
interface was already there, or was being planned?  Can you give me
any details?  Could we possibly help?

Another question:  The current checksum code deals only with "md5".
Support for newer Kerberos encryption types uses keyed hashes.  In an
extreme case, support for the rc4-hmac Kerberos encryption type
requires a new hash key be derived for each rpc.  Would this interface
be able to deal with changing keys as well?  In that same case, the
"rc4" cipher key changes with each rpc as well.

Thanks,
K.C.
