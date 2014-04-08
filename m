Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756382AbaDHMVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 08:21:49 -0400
Date: Tue, 8 Apr 2014 08:21:40 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Andy Adamson <androsadamson@gmail.com>, chuck.lever@oracle.com,
        trond.myklebust@primarydata.com
Subject: v4.0 CB_COMPOUND authentication failures
Message-ID: <20140408082140.340c1328@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've recently been hunting down some problems with delegation handling
and have run across a problem with the client authenticates CB_COMPOUND
requests. I could use some advice on how best to fix it.

Specifically, check_gss_callback_principal() tries to look up the
callback client and then tries to compare the ticket in it against the
clp->cl_hostname:

        /* Expect a GSS_C_NT_HOSTBASED_NAME like "nfs@serverhostname" */

        if (memcmp(p, "nfs@", 4) != 0)
                return 0;
        p += 4;
        if (strcmp(p, clp->cl_hostname) != 0)
                return 0;
        return 1;

The problem is that there is no guarantee that those hostnames will be
the same. If, for instance, I mount "foo:/" and the SPN is
"nfs/foo.bar.baz" that strcmp will return true, and the CB_COMPOUND
request will get tossed out [1]. Ditto if I happen to mount a CNAME of the
server.

Now that we try to use krb5 on the callback channel even when sec=sys
is specified, this is very problematic.

I think that the ideal thing would be to stash the SPN that we use to
do the SETCLIENTID call and use that in the comparison above.
Unfortunately, the rpc_cred doesn't really seem to carry this info and
I don't see where we get enough information in the rpc.gssd downcall to
figure out what that SPN should be.

Anyone have thoughts or should we just remove the above check until we
come up with a better way to do this?

[1]: there's another bug that can cause the client to send a bogus
     reply instead of dropping the request as intended, but that's
     relatively simple to fix.
-- 
Jeff Layton <jlayton@redhat.com>
