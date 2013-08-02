Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hapkido.dreamhost.com ([66.33.216.122]:49651 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132Ab3HBUUt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Aug 2013 16:20:49 -0400
MIME-Version: 1.0
In-Reply-To: <20130802095555.07a2cda3@tlielax.poochiereds.net>
References: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
	<20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
	<20130802095555.07a2cda3@tlielax.poochiereds.net>
Date: Fri, 2 Aug 2013 15:20:07 -0500
Message-ID: <CAK3OfOhoeya1t76TaWG_g3jE24B_uXmDFxLqhriEgx0DEdzZqA@mail.gmail.com>
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for persistent
 per-UID kerberos caches
From: Nico Williams <nico@cryptonector.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: David Howells <dhowells@redhat.com>, keyrings@linux-nfs.org,
        "Eric W. Biederman" <ebiederm@xmission.com>, simo@redhat.com,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, linux-nfs@vger.kernel.org,
        krbdev@mit.edu, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 2, 2013 at 8:55 AM, Jeff Layton <jlayton@redhat.com> wrote:
> Isn't it possible to have a valid uid of (unsigned int)-1? I know that
> at least some sites use that for "nobody". Why not just require passing
> in the correct UID?

POSIX requires valid UIDs to be non-nengative.  POSIX does not require
uid_t to be signed or unsigned.  POSIX does make use of (uid_t)-1 as a
sentinel (e.g., in setreuid(2)).  (uid_t)-1 is special.  Do not use
it.

As an aside, note that on Solaris 10 and less uid_t was signed, so
UIDs 2^31..2^32-2 were unusable.  Interop with S10 and less requires
that you not use such UIDs.  Ditto gid_t and GIDs.

Also note that in Solaris 11 uid_t is unsigned BUT the range of UIDs
2^31..2^32-2 is still reserved (for automatic, on-demand,
non-persistent allocation for ID mapping purposes).  Interop with S11
requires that you not use such UIDs.  Ditto gid_t and GIDs.

Nico
--
