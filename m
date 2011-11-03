Return-Path: linux-nfs-owner@vger.kernel.org
Received: from DMZ-MAILSEC-SCANNER-8.MIT.EDU ([18.7.68.37]:61324 "EHLO
	dmz-mailsec-scanner-8.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752773Ab1KCV6R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 17:58:17 -0400
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Nico Williams <nico@cryptonector.com>, dhowells <dhowells@redhat.com>,
        linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>
Subject: Re: GSSAPI Proxy initiative
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	<CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
	<1320332310.7734.643.camel@willson.li.ssimo.org>
	<CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
	<1320337903.7734.670.camel@willson.li.ssimo.org>
	<CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
	<1320352784.18396.109.camel@lade.trondhjem.org>
From: Tom Yu <tlyu@mit.edu>
Date: Thu, 03 Nov 2011 17:58:12 -0400
In-Reply-To: <1320352784.18396.109.camel@lade.trondhjem.org> (Trond Myklebust's message of "Thu, 03 Nov 2011 16:39:44 -0400")
Message-ID: <ldvsjm4kgwb.fsf@cathode-dark-space.mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> writes:

> Linux already has per-user, per-process and per-thread keyrings which
> offer a high security storage solution for keys. The problem with those
> is that they are difficult to use in an asynchronous context when the
> original user's process/thread context is no longer available to us.
>
> Ideally, though, that's what we'd like to see used.

Perhaps I misunderstand what you're proposing to use the keyring for,
but I would like to clarify a few things.

Opaque key storage is probably not the right abstraction level to
represent the kind of privilege separation we want here.  It's clearly
already possible to use the Linux keyring, TPM, smart cards, etc. to
achieve opaque key storage.

One of the original goals is privilege separation.  The GSS proxy can
allow an unprivileged process to perform specific restricted
operations with key material such as a host key, instead of the mostly
unrestricted encryption, decryption, etc. access that you would get
with an opaque or unextractable key model.  The proxy could limit the
client's use of the key to gss_accept_sec_context(), without allowing
the sort of generalized cryptographic operations that would allow the
client to, say, forge a PAC signature.
