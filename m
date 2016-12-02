Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f194.google.com ([209.85.213.194]:34474 "EHLO
        mail-yb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753396AbcLBJXB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2016 04:23:01 -0500
Received: by mail-yb0-f194.google.com with SMTP id h184so4868733ybb.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Dec 2016 01:23:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1476190256-1677-3-git-send-email-agruenba@redhat.com>
References: <1476190256-1677-1-git-send-email-agruenba@redhat.com> <1476190256-1677-3-git-send-email-agruenba@redhat.com>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 2 Dec 2016 10:22:58 +0100
Message-ID: <CAELBmZAF7stgY3DxaeZLd2Nt+c5rTnVC_yFORGxxN1HHoctPaQ@mail.gmail.com>
Subject: Re: [PATCH v27 02/21] vfs: Add MAY_CREATE_FILE and MAY_CREATE_DIR
 permission flags
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 11, 2016 at 2:50 PM, Andreas Gruenbacher
<agruenba@redhat.com> wrote:
> Richacls distinguish between creating non-directories and directories. To
> support that, add an isdir parameter to may_create(). When checking
> inode_permission() for create permission, pass in an additional
> MAY_CREATE_FILE or MAY_CREATE_DIR mask flag.
>
> Add may_replace() to allow checking for delete and create access when
> replacing an existing file in vfs_rename().

That works for plain rename, but not for RENAME_EXCHANGE: is_dir and
new_is_dir may be different, which means we can be deleting a
non-directory *and* creating a directory in one dir and vice versa in
the other.

Thanks,
Miklos
