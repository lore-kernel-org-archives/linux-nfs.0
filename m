Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35700 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbdFOJJa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jun 2017 05:09:30 -0400
Date: Thu, 15 Jun 2017 10:09:28 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 03/27] VFS: Make get_mnt_ns() return the namespace [ver
 #5]
Message-ID: <20170615090928.GF31671@ZenIV.linux.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
 <149745334260.10897.8377331388521502715.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <149745334260.10897.8377331388521502715.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 14, 2017 at 04:15:42PM +0100, David Howells wrote:
> Make get_mnt_ns() return the namespace it got a ref on for consistency with
> other namespace ref getting functions.

Is there any point in doing that?  I mean, it's not used in your patchset anymore
and existing callers are a mixed bag...
