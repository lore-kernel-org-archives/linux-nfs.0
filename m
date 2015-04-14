Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56865 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880AbbDNTXa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2015 15:23:30 -0400
Date: Tue, 14 Apr 2015 12:23:25 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Zach Brown <zab@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org
Subject: Re: [PATCH RFC 1/3] vfs: add copy_file_range syscall and vfs helper
Message-ID: <20150414192325.GB20599@infradead.org>
References: <CAHQdGtSwSf0j6ge7rCue48bZ08212Ny2Crz9WMadSno11N8z_g@mail.gmail.com>
 <20150411000208.GA20949@lenny.home.zabbo.net>
 <CAHQdGtSaaPHbvtBM3yVGtAFpEAP8ZquYvErknq_rCoCCK+W2bA@mail.gmail.com>
 <20150411090402.67d22d02@tlielax.poochiereds.net>
 <20150414165344.GA21421@infradead.org>
 <552D4B5D.3090904@Netapp.com>
 <20150414181911.GA2080@fieldses.org>
 <20150414182241.GB23129@lenny.home.zabbo.net>
 <20150414182906.GB2080@fieldses.org>
 <20150414185408.GC23129@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150414185408.GC23129@lenny.home.zabbo.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 14, 2015 at 11:54:08AM -0700, Zach Brown wrote:
> Is this relying on btrfs range cloning being atomic?  It certainly
> doesn't look atomic.  It can modify items across an arbitrarily large
> number of leaf blocks.  It can make the changes across multiple
> transactions which could introduce partial modification on reboot after
> crashes.  It can fail (the dynamic duo: enomem, eio) and leave the
> desintation partially modified.

I didn't mean atomic in the failure atomic sense, but in the sense of
being atomic vs other writes, similar to how Posix specifies it for
writes vs other writes.  Guess I need to express this intent better.
