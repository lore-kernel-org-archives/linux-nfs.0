Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752515Ab0AWDs3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2010 22:48:29 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <4B599FA5.5080103@suse.de>
References: <4B599FA5.5080103@suse.de> <4B56F565.7080104@suse.de> <29178.1264072027@redhat.com>
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: dhowells@redhat.com, trond.myklebust@netapp.com,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC][PATCH] nfs: don't assume fscache_acquire_cookie will always succeed
Date: Sat, 23 Jan 2010 03:48:06 +0000
Message-ID: <30067.1264218486@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Suresh Jayaraman <sjayaraman@suse.de> wrote:

> As I understand we should not be calling any fscache related functions when
> the client doesn't use fsc mount option (though CONFIG_NFS_FSCACHE is set),
> right?

Not necessarily.  It can be done that way, but if you just set the top-level
cookie to NULL, fscache.h will just od the right thing all the way down.  It
adds a test and jump to each path.

Anyway, I can't really look at it now, I'm on holiday in NZ for a couple more
weeks.

David
