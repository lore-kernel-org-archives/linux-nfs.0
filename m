Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106AbcEWJdg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 May 2016 05:33:36 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20160523082230.GA21308@infradead.org>
References: <20160523082230.GA21308@infradead.org> <20160510070421.GB30896@infradead.org> <6897.1462868755@warthog.procyon.org.uk> <20160512091141.GA22420@infradead.org> <3204439.9qcmCY96fi@wuerfel>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, Arnd Bergmann <arnd@arndb.de>,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 23 May 2016 10:33:33 +0100
Message-ID: <25305.1463996013@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig <hch@infradead.org> wrote:

> Honestly I think this really matters on the amount of 'emulation' we
> need - if it's just adding a new flag that can be trivially generated
> in the syscall stub in userland that's probably fine, but if we have
> actually differing semantics (like the stat weak attributes) I'd rather
> have a properly documented syscall.  If we otherwise need to rewrite
> whole structures I'd much rather do that in kernel space.

I very much agree.

> And to get back to stat: if would be really useful to coordinate the
> new one with glibc so that we don't end up with two different stat
> structures again like we do for a lot of platforms at the moment.

I've tried reaching out to them and others, but no one responded.

David
