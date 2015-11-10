Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:33052 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295AbbKJMjy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2015 07:39:54 -0500
Received: by lbbkw15 with SMTP id kw15so113136718lbb.0
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2015 04:39:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151110112943.GA17038@infradead.org>
References: <1447067343-31479-1-git-send-email-agruenba@redhat.com>
	<20151110112943.GA17038@infradead.org>
Date: Tue, 10 Nov 2015 13:39:52 +0100
Message-ID: <CAHc6FU5g7=wd1Wt4+GCaLJjNu7giruZyAON3VcYn-A=ffYMsmw@mail.gmail.com>
Subject: Re: [PATCH v15 00/22] Richacls (Core and Ext4)
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 10, 2015 at 12:29 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Nov 09, 2015 at 12:08:41PM +0100, Andreas Gruenbacher wrote:
>> Here is another update to the richacl patch queue.  This posting contains
>> the patches ready to be merged; the patches later in the queue still need
>> some more review.
>
> It still has the same crappy fs interfaces with lots of boilerplate
> code

Could you please be more specific so that I can trace this complaint
to some actual code?

> and still abuses xattrs instead of a proper syscall interface.
> That's far from being ready to merge.

The xattr syscall interface is what's used for very similar kinds of
things today; using it for richacls as well sure does not count as
abuse. Things could be improved in the xattr interface and in its
implementation, but we need more substantial reasons than that for
reimplementing the wheel once again.

[The recently discussed xattr fixes
(http://permalink.gmane.org/gmane.linux.file-systems/101502) and two
small POSIX ACL fixes
(http://permalink.gmane.org/gmane.linux.file-systems/101499) are
currently stuck waiting for Al, by the way.]

Thanks,
Andreas
