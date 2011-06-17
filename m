Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755075Ab1FQJ5F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jun 2011 05:57:05 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <BANLkTimxJ5kHOODSPqRPcgbObjZbfT59uw@mail.gmail.com>
References: <BANLkTimxJ5kHOODSPqRPcgbObjZbfT59uw@mail.gmail.com> <20110616235600.14345.16839.stgit@warthog.procyon.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, akpm@linux-foundation.org, jmorris@namei.org,
        shirishpargaonkar@gmail.com, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH] KEYS/DNS: Fix ____call_usermodehelper() to not lose the session keyring
Date: Fri, 17 Jun 2011 10:56:51 +0100
Message-ID: <23040.1308304611@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> PS. Possibly it might make more sense to just put the "struct cred *"
> pointer into the "struct subprocess_info" and not change any of the
> function prototypes at all?

That's the way I did it originally, but someone thought doing it with an init
function was a better idea:-/

Your suggestion is slightly complicated by the capability restriction stuff
that caused the breakage.  That needs to hack the creds at some point.

David
