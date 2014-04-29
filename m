Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f41.google.com ([74.125.83.41]:56104 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbaD2IrL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 04:47:11 -0400
Message-ID: <535F670B.4060704@gmail.com>
Date: Tue, 29 Apr 2014 10:47:07 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: mtk.manpages@gmail.com,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        lkml <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        samba-technical@lists.samba.org, linux-nfs@vger.kernel.org
Subject: Re: OFD ("file private") locks and NFS
References: <535F651E.6090204@gmail.com>
In-Reply-To: <535F651E.6090204@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[CC+= linux-nfs@]

On 04/29/2014 10:38 AM, Michael Kerrisk (man-pages) wrote:
> Hi Jeff,
> 
> I've been looking a bit at the fcntl() documentation of traditional 
> (F_SETLK) record locking, and a question just jumped out at me. Is 
> it worth considering some future-proofing in the design of OFD locks
> ("open file description locks", formerly known as "file-private locks")?
> 
> What I am thinking of here is that on some systems, the traditional
> 'struct flock' has a nonstandard field, l_sysid, that is used on F_GETLK 
> to identify the remote system on which a lock is held. Should the design
> of OFD locks allow for such a field (now, or in the future), which might 
> be useful in the context of locking on network file systems such as NFS.
> 
> Put more simply, should the new OFD locking system be using a new
> structure for describing locks, rather than the traditional 'struct
> flock'? Defining a new structure, might be useful to allow for
> future extensions to the API.

Just add one further detail here. What I'm thinking is, maybe instead there
should be something like:

struct flockx {
    int flags;
    /* Other fields like 'struct flock' */
    char reserved[32];	/* Or some suitable value */
}

That flags field might always be zero for now, but in the future it 
could be used on the setlk and getlk operations to indicate the presence
of additional fields in the structure.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
