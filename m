Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:58462 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbbKXULE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 15:11:04 -0500
From: Arnd Bergmann <arnd@arndb.de>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: David Howells <dhowells@redhat.com>, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 01/12] Ext4: Fix extended timestamp encoding and decoding
Date: Tue, 24 Nov 2015 21:10:53 +0100
Message-ID: <3495329.crWmoA5ACn@wuerfel>
In-Reply-To: <20151124193646.GA3482@thunk.org>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk> <20151120145434.18930.89755.stgit@warthog.procyon.org.uk> <20151124193646.GA3482@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday 24 November 2015 14:36:46 Theodore Ts'o wrote:
> This is the patch I would prefer to use (and in fact which I have
> added to the ext4 tree):
> 
> There are issues with 32-bit vs 64-bit encoding of times before
> January 1, 1970, which are handled with this patch which is not
> handled with what you have in your patch series.  So I'd prefer if you
> drop this patch, and I'll get this sent to Linus as a bug fix for 4.4.

I'm happy with either one. Apparently both Davids have arrived with
almost the same algorithm and implementation, with the exception of
the pre-1970 handling you mention there.

	Arnd
