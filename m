Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adler.unx.csupomona.edu ([134.71.247.15]:40713 "EHLO
	adler.unx.csupomona.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757614Ab0J1Aad (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 20:30:33 -0400
Received: from localhost (localhost [127.0.0.1])
	by adler.unx.csupomona.edu (Postfix) with ESMTP id B54821000A0
	for <linux-nfs@vger.kernel.org>; Wed, 27 Oct 2010 17:24:53 -0700 (PDT)
Received: from adler.unx.csupomona.edu ([127.0.0.1])
	by localhost (adler.unx.csupomona.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fb0UkH2uuHHn for <linux-nfs@vger.kernel.org>;
	Wed, 27 Oct 2010 17:24:53 -0700 (PDT)
Received: from localhost (woof.iitsystems.csupomona.edu [134.71.248.29])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: bldewolf)
	by adler.unx.csupomona.edu (Postfix) with ESMTPSA id 8D00C100094
	for <linux-nfs@vger.kernel.org>; Wed, 27 Oct 2010 17:24:53 -0700 (PDT)
Date: Wed, 27 Oct 2010 17:24:52 -0700
From: Brian De Wolf <bldewolf@csupomona.edu>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: rpc.gssd still spammed in 2.6.35
Message-ID: <20101027172452.68b944ec@csupomona.edu>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Greetings,

I recently started testing a build of 2.6.35 to hopefully relieve some
issues we have on our login boxes.  Specifically, I was after this
commit:
http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commit;h=126e216a8730532dfb685205309275f87e3d133e

The issue we've run into is that some user loses their credentials,
but has a process looping on a read/write of their Kerberized NFSv4 home
directory without checking the return value.  Not only did this spam
logs, but it also prevents rpc.gssd from handling anyone else's logins,
effectively taking down the service for anyone not already connected.

I was hoping this commit would protect rpc.gssd from any potential
flooding of requests, but it all depends on how the user loses their
credentials. If their credentials have expired or their caches become
corrupt, rpc.gssd returns EKEYEXPIRED and the kernel rate limits the
requests to rpc.gssd via negative caching.

If the user's credential cache gets destroyed, however, rpc.gssd
returns EACCES, and the user process can cause the kernel to hammer
rpc.gssd. The kicker here is that pam_krb5 destroys credentials on
logout by default, so if someone's using screen or long background
processes in their home directory, it's a ticking time bomb waiting to
destroy rpc.gssd.

That's assuming a benign user, as well.  A malicious user could easily
kdestroy, wait for their credentials to expire from the cache in the
kernel, and start tying up rpc.gssd with failed requests.


With this in mind, I initially patched the kernel to negative cache
entries with EACCES errors, in addition to EKEYEXPIRED errors.  But the
more that I thought about it, the more it seemed appropriate to subject
all possible errors to negative caching.  The underlying question is,
is there any possible error from rpc.gssd where it would be appropriate
to allow a process to cause another request to rpc.gssd immediately?
If there isn't, negative caching all errors seems reasonable.

Here's a simple patch implementing the behavior of negative caching of
every failed request, as a proof of concept, I guess.  With it applied,
I have yet to produce a scenario where rpc.gssd becomes unresponsive.

Let me know what you think.  I'd love to see a fix for this behavior
enter the kernel at some point, as it's been rather disruptive on our
login boxes lately.


diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3835ce3..38bdf90 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -362,7 +362,7 @@ gss_handle_downcall_result(struct gss_cred *gss_cred, struct gss_upcall_msg *gss
                clear_bit(RPCAUTH_CRED_NEGATIVE, &gss_cred->gc_base.cr_flags);
                gss_cred_set_ctx(&gss_cred->gc_base, gss_msg->ctx);
                break;
-       case -EKEYEXPIRED:
+       default:
                set_bit(RPCAUTH_CRED_NEGATIVE, &gss_cred->gc_base.cr_flags);
        }
        gss_cred->gc_upcall_timestamp = jiffies;
