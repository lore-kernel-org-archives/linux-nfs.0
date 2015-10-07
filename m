Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40949 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbbJGHvI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 03:51:08 -0400
Date: Wed, 7 Oct 2015 00:50:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Austin S Hemmelgarn <ahferroin7@gmail.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH v8 00/41] Richacls
Message-ID: <20151007075053.GA8660@infradead.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
 <20151004062313.GA20212@infradead.org>
 <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
 <5612C85C.2060407@gmail.com>
 <20151006094935.GA14144@infradead.org>
 <CAHc6FU5aZJDC3N1iGyVeHfbqMyquM93ONJvUR-t0a9+AjmtAXQ@mail.gmail.com>
 <CF738526-0807-4CE5-A52B-413164D41AA9@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CF738526-0807-4CE5-A52B-413164D41AA9@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 06, 2015 at 02:26:09PM -0600, Andreas Dilger wrote:
> And any disk filesystems that have their own non-POSIX ACLs, such as HFS, NTFS, ZFS would presumably also need to map the in-kernel Richacl format to their on-disk format.

No, we did this mistake with Posix ACLs, and we're not going to repeat
it here.  Filesystems with their own slightly different ACLs must not
reuse the interface.
