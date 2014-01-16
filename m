Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:61627 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbaAPQN3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jan 2014 11:13:29 -0500
Received: by mail-qc0-f181.google.com with SMTP id e9so2447034qcy.26
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jan 2014 08:13:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140116154132.GB16829@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
	<1389807296.16290.32.camel@tucsk.piliscsaba.szeredi.hu>
	<20140115175723.GA4596@fieldses.org>
	<CAJfpegs0+t4S1y9mhRMJMAERh-a95KjK_JQ7F5SRrfsNZOdoMA@mail.gmail.com>
	<20140116154132.GB16829@fieldses.org>
Date: Thu, 16 Jan 2014 17:13:28 +0100
Message-ID: <CAJfpegumqYe2oQ3at8w8OJFhNx38c6XBtdnyb4H6O=AGihfH-Q@mail.gmail.com>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
From: Miklos Szeredi <miklos@szeredi.hu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Miklos Szeredi <mszeredi@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 16, 2014 at 4:41 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> And, sorry, I did miss that you said "non-directory".  But I think you
> have that backwards: d_splice_alias looks like:
>
>         if (inode && S_ISDIR(inode->i_mode)) {
>                 ...
>         } else {
>                 d_instantiate(dentry, inode);
>                 if (d_unhashed(dentry))
>                         d_rehash(dentry);
>         }
>
> So it ignores any existing aliases in the non-directory case.

Okay.

>
> d_materialise_unique by contrast calls __d_instantiate_unique, which
> looks like it should avoid adding duplicates.
>
> So I think switching everyone to d_materialiase_unique would result in
> fewer dentries.  But I've never seen any complaint about the issue and
> like you don't see a reason this would matter much either way.

So, yes, d_materialise_unique() looks like it has superior
functionality compared to d_splice_alias().

Thanks,
Miklos
