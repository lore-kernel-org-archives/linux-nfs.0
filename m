Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:52501 "EHLO
        mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938851AbcISNK6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2016 09:10:58 -0400
Date: Mon, 19 Sep 2016 09:10:50 -0400 (EDT)
From: Frank Sorenson <sorenson@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Message-ID: <1272446089.121606.1474290650680.JavaMail.zimbra@redhat.com>
In-Reply-To: <7EC0B2B1-CE1A-4509-9FE2-A5D6529626DA@primarydata.com>
References: <1474056735-4008-1-git-send-email-sorenson@redhat.com> <7EC0B2B1-CE1A-4509-9FE2-A5D6529626DA@primarydata.com>
Subject: Re: [PATCH] sunrpc: include gid in the rpc_cred_cache hash
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


----- Original Message -----
> From: "Trond Myklebust" <trondmy@primarydata.com>
> To: "Frank Sorenson" <sorenson@redhat.com>
> Cc: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
> Sent: Friday, September 16, 2016 4:37:39 PM
> Subject: Re: [PATCH] sunrpc: include gid in the rpc_cred_cache hash

> > +rpcauth_hash_acred(struct auth_cred *acred, unsigned int hashbits)
> > +{
> > +	return hash_64(from_kgid(&init_user_ns, acred->gid) |
> > +		(from_kuid(&init_user_ns, acred->uid) << (sizeof(gid_t) * 8)),
> > +		hashbits);
> > +}
> > +

> NACK. The choice of only using the uid when hashing was deliberate;
> RPCSEC_GSS is keyed only on the uid…
> If you want to do this in order to accelerate AUTH_SYS lookups, then you need
> to push the hashing down to the auth flavour ops.

I recognize that RPCSEC_GSS only uses the uid as a key.  However, RPCSEC_GSS
calls rpcauth_lookup_credcache with an auth_cred, just like AUTH_SYS, only with
the gid set to 0.  Including the gid in the hash has no effect on RPCSEC_GSS;
if the function is flipped to shift the gid instead of the uid, it even hashes
to the same result as it did previously.

Adding a shift and bitwise OR to the hash is more straightforward and
efficient than adding the logic to provide a per-auth flavour hash op that
differs only in that it doesn't shift and OR a 0 value.

Or are there additional benefits to be gained from each having its own hash
function?


Thanks,

Frank
--
Frank Sorenson
sorenson@redhat.com
Senior Software Maintenance Engineer
Global Support Services - filesystems
Red Hat
