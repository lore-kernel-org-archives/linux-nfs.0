Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:35050 "EHLO
	mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359AbcBNXMX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Feb 2016 18:12:23 -0500
Received: by mail-vk0-f43.google.com with SMTP id e6so95068758vkh.2
        for <linux-nfs@vger.kernel.org>; Sun, 14 Feb 2016 15:12:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56C0F150.60008@gmail.com>
References: <56B770B6.7040803@gmail.com>
	<56B77262.7090107@gmail.com>
	<CAHc6FU5__xbKm4mg8+fK_ZW5ZYsDoQcYBBvQg573Eq4ERDsROw@mail.gmail.com>
	<56C0F150.60008@gmail.com>
Date: Mon, 15 Feb 2016 00:12:21 +0100
Message-ID: <CAHc6FU49uRb11HhO655jimn_CzLrDyGHAB2iDAv92cftCCXkEA@mail.gmail.com>
Subject: Re: richacl(7) man page review comments
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, lkml <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        Dave Chinner <david@fromorbit.com>,
        Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Andreas Dilger <adilger@dilger.ca>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 14, 2016 at 10:27 PM, Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> On 02/12/2016 11:25 PM, Andreas Gruenbacher wrote:
>> We could sure move acl(5) and richacl(7) there.
>
> We already have acl(5) (now "acl(7)" in man pages) ;-).

Hmm, I can't find that page either in
git://git.kernel.org/pub/scm/docs/man-pages/man-pages or on
http://man7.org/. Are you sure you don't mean xattr.7 == attr.5 which
documents the xattr syscall interface?

Andreas
