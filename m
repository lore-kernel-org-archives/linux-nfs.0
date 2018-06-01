Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:53160 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751982AbeFANxG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Jun 2018 09:53:06 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <22188.1527860316@warthog.procyon.org.uk>
References: <22188.1527860316@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, steved@redhat.com, Anna.Schumaker@Netapp.com,
        jumitche@redhat.com, linux-nfs@vger.kernel.org,
        viro@ZenIV.linux.org.uk
Subject: Re: NFS mount-api patches
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 01 Jun 2018 14:53:03 +0100
Message-ID: <22758.1527861183@warthog.procyon.org.uk>
To: unlisted-recipients:; (no To-header on input)@mail.corp.redhat.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> Al pulled my mount API patches into his tree and fixed them up.  I've ported
> my NFS mount-API patches on top of them, so they apply and build (at least
> with my settings).  Do you have time now to have a poke at them to get them to
> work?  (I'm a bit tight for time this afternoon, so I don't have time to test
> them till next week)

Oh - it needs to take an active ref on the superblock any time you assign to
fc->root where you didn't inherit one from sget_fc() or vfs_get_super():

	atomic_inc(&sb->s_active);

as this will be deactivated by put_fs_context() if ->root is set.

David
