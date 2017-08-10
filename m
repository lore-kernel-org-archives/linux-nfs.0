Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34026 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752109AbdHJQwL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Aug 2017 12:52:11 -0400
MIME-Version: 1.0
In-Reply-To: <9674.1502283345@warthog.procyon.org.uk>
References: <20170807212355.29127-1-kolga@netapp.com> <9674.1502283345@warthog.procyon.org.uk>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 10 Aug 2017 12:52:09 -0400
Message-ID: <CAN-5tyE11DaCCXdn3y+Q4V+Lyt_UgtzU+JBhwP68gxQc5_v6pQ@mail.gmail.com>
Subject: Re: [RFC v3 0/3] VFS/NFS support to destroy FS credentials
To: David Howells <dhowells@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 9, 2017 at 8:55 AM, David Howells <dhowells@redhat.com> wrote:
> You may also want to flush any outstanding dirty data and wait for in-progress
> operations.

Sorry for the delayed response but I've been thinking about it as this
is a tricky one (for me at least).

Even currently, each file system needs a way to deal with flushing
cached data to storage in the situation where creds might have expired
in between when the kernel returned control back to the user but
before all of buffered writes are flushed. NFS4.1 has wording in the
spec for using machine credentials in that case.

At the VFS layer, there no what to tell which dirty data belongs to
which user. Flushing all data under the superblock seems like a bad
idea?
