Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39109 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237Ab2KFNFf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Nov 2012 08:05:35 -0500
Date: Tue, 6 Nov 2012 08:05:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before
 connecting local transports
Message-ID: <20121106130526.GB6718@fieldses.org>
References: <20121008105437.18668.99905.stgit@localhost.localdomain>
 <20121009193506.GA19680@fieldses.org>
 <5098E31A.5080801@parallels.com>
 <20121106120642.GA6718@fieldses.org>
 <5098FE5F.7030709@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5098FE5F.7030709@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 06, 2012 at 04:11:11PM +0400, Stanislav Kinsbursky wrote:
> 06.11.2012 16:06, J. Bruce Fields пишет:
> >On Tue, Nov 06, 2012 at 02:14:50PM +0400, Stanislav Kinsbursky wrote:
> >>09.10.2012 23:35, J. Bruce Fields пишет:
> >>>Cc'ing Eric since I seem to recall he suggested doing it this way?
> >>>
> >>>Seems OK to me, but maybe that swap_root should be in common code?  (Or
> >>>maybe we could use set_fs_root()?)
> >>>
> >>
> >>This patch is not good since, as Eric mentioned, all kernel threads
> >>share same fs struct.
> >>We can swap whole fs struct. Or we can unshare fs struct
> >>(unshare_fs_struct() is exported) and swap root in this case.
> >>But this approach is to close to set_fs_root() logic, which is not
> >>exported and seems there are some valid reasons for it.
> >
> >What are those reasons?
> >
> 
> I don't know them.
> Trond told, that Al doesn't like the idea of set_fs_root() exporting.
> 
> >Googling found one previous thread:
> >
> >	http://thread.gmane.org/gmane.linux.kernel/1259986/focus=47687
> >
> >There Trond requests an ACK from Al or Cristoph for the export, but I
> >don't see either an ACK or any objection.
> >
> 
> Cristoph told me on LSF something line "No ... way", when I asked
> him about set_fs_root() exporting.
> But I had no opportunity to ask why.

So, Al or Christoph: NFS calls up to rpcbind from the kernel using
AF_LOCAL, so it looks up a path when it connects.  We'd like to export
set_fs_root() so we can temporarily put our task in the right namespace
around the connect call.  Is that reasonable?

I just want to get a reason on record so we stop going in circles here.

--b.
