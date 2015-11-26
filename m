Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbbKZP2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Nov 2015 10:28:42 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20151124193646.GA3482@thunk.org>
References: <20151124193646.GA3482@thunk.org> <20151120145422.18930.72662.stgit@warthog.procyon.org.uk> <20151120145434.18930.89755.stgit@warthog.procyon.org.uk>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: dhowells@redhat.com, arnd@arndb.de, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 01/12] Ext4: Fix extended timestamp encoding and decoding
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 26 Nov 2015 15:28:36 +0000
Message-ID: <7814.1448551716@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Theodore Ts'o <tytso@mit.edu> wrote:

> This is the patch I would prefer to use (and in fact which I have
> added to the ext4 tree):
> 
> There are issues with 32-bit vs 64-bit encoding of times before
> January 1, 1970, which are handled with this patch which is not
> handled with what you have in your patch series.  So I'd prefer if you
> drop this patch, and I'll get this sent to Linus as a bug fix for 4.4.

Fine by me.

Acked-by: David Howells <dhowells@redhat.com>
