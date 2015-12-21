Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbbLUXV2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Dec 2015 18:21:28 -0500
In-Reply-To: <20151204120633.GI14427@amd>
References: <20151204120633.GI14427@amd> <20151120145422.18930.72662.stgit@warthog.procyon.org.uk> <20151120145457.18930.79678.stgit@warthog.procyon.org.uk>
To: Pavel Machek <pavel@ucw.cz>
Cc: dhowells@redhat.com, arnd@arndb.de, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 03/12] statx: Add a system call to make enhanced file info available
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
From: David Howells <dhowells@redhat.com>
Date: Mon, 21 Dec 2015 23:21:24 +0000
Message-ID: <4234.1450740084@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pavel Machek <pavel@ucw.cz> wrote:

> But fstat() is really different operation to stat() -- tell me about
> my file descriptor vs. tell me about this filename, and ptrace (and
> some "security" solutions) might want to allow one but disallow the
> second. I'd not group them together..

You can argue it either way.  I think Linus came down on the side of combining
them.

David
