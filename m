Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755712Ab3IZLYW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 07:24:22 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1380175008-13090-1-git-send-email-olof@lixom.net>
References: <1380175008-13090-1-git-send-email-olof@lixom.net> <20130920150927.16220.33305.stgit@warthog.procyon.org.uk>
To: Olof Johansson <olof@lixom.net>
Cc: dhowells@redhat.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFS: Don't use debug-printk-only local variables
Date: Thu, 26 Sep 2013 12:24:19 +0100
Message-ID: <1221.1380194659@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Olof Johansson <olof@lixom.net> wrote:

> Due to commit 996a2493ed5d3a8d5db03b560fcbbf1ca3f10897 (NFS:
> Use i_writecount to control whether to get an fscache cookie in
> nfs_open(), in two instances a local variable is only used in debug
> print statements. Said statements might be compiled out, which results
> in unused variable warnings:

Yeah, Fengguang's magic compile farm has also complained about that.

David
