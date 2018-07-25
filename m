Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:60710 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729524AbeGYUob (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Jul 2018 16:44:31 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CA+55aFwvKerkzigZmm0zrUTnsqDpJs0XBtX72Ltmek+_ic-KmA@mail.gmail.com>
References: <CA+55aFwvKerkzigZmm0zrUTnsqDpJs0XBtX72Ltmek+_ic-KmA@mail.gmail.com> <7828.1532527332@warthog.procyon.org.uk> <CA+55aFy2v3OW+mmSDF4MPWW673WsJEdQef3LChWg5k9=_k9ggg@mail.gmail.com> <25183.1532542685@warthog.procyon.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, kiran.modukuri@gmail.com,
        linux-cachefs@redhat.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [GIT PULL] fscache and cachefiles fixes
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 25 Jul 2018 20:31:24 +0100
Message-ID: <1055.1532547084@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Okay, I posted four patches on 5th July:

	https://lore.kernel.org/lkml/153080826773.5496.7106875523806885716.stgit@warthog.procyon.org.uk/

These five patches are the same aggregate changes, just with the first patch
split and a description composed for both parts:

	warthog>git diff fscache-fixes-20180705  fscache-fixes-20180725
	warthog>

The patch series as a whole got tested by Scott Mayhew whilst seeing if they
cured a bug he was looking at:

	https://marc.info/?l=linux-nfs&m=153191593807248&w=2

I've also ported them to RHEL-7 where they've undergone some automated testing
with iozone.

David
