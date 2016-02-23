Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:33985 "EHLO
	mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbcBWLOh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Feb 2016 06:14:37 -0500
Received: by mail-vk0-f50.google.com with SMTP id e185so157560256vkb.1
        for <linux-nfs@vger.kernel.org>; Tue, 23 Feb 2016 03:14:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56CC3B4A.7070204@gmail.com>
References: <56B770B6.7040803@gmail.com>
	<56B77262.7090107@gmail.com>
	<CAHc6FU5__xbKm4mg8+fK_ZW5ZYsDoQcYBBvQg573Eq4ERDsROw@mail.gmail.com>
	<56C0F23C.7030902@gmail.com>
	<CAHc6FU4CCrcrA6=oCiq2A5rGd9CCGELaTZq6tGpmd2jcV_Zp4A@mail.gmail.com>
	<56CA2EEB.9080504@gmail.com>
	<CAHc6FU46vO8NM3cvFH7b8X7U9R+m6wcYj8EQKVnSQkiY3Q051A@mail.gmail.com>
	<56CC3B4A.7070204@gmail.com>
Date: Tue, 23 Feb 2016 12:14:35 +0100
Message-ID: <CAHc6FU4dSsqVBJsN3jCAPrEtX5beiJ9Km_g=r53kJ+8iQPOSUA@mail.gmail.com>
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

On Tue, Feb 23, 2016 at 11:58 AM, Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> So, in terms of actually testing this stuff, is it just a matter of
> applying your patch series to the kernel, building the kernel, pulling
> the RichACL user-space tools from Git, and mount(8)ing a filesystem with
> the right option?

You'd create a test filesystem with the appropriate feature flag set
(mkfs.ext4 -O richacl2 / mkfs.xfs -m richacl=1), RichACLs are not
enabled by mount options anymore. This will obviously require versions
of e2fsprogs / xfsprogs that understand the feature. If you want
coreutils support which isn't strictly necessary, you'll need the
patched version too. Other than that, it's really simple.

Andreas
