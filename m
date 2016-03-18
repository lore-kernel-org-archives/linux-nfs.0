Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:33292 "EHLO
	mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754698AbcCRIsP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Mar 2016 04:48:15 -0400
Received: by mail-vk0-f50.google.com with SMTP id k1so133407782vkb.0
        for <linux-nfs@vger.kernel.org>; Fri, 18 Mar 2016 01:48:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAH2r5mu66qi=G6sMNQzS_Ciu9ctyS4Q+bKskVqk1Hj5_x7FWng@mail.gmail.com>
References: <1458166743-18488-1-git-send-email-agruenba@redhat.com>
	<CAH2r5mu66qi=G6sMNQzS_Ciu9ctyS4Q+bKskVqk1Hj5_x7FWng@mail.gmail.com>
Date: Fri, 18 Mar 2016 09:48:14 +0100
Message-ID: <CAHc6FU4ZQQ9qQH+_3cGTO3GjH4AEfgfYzezU5VMWHFG9C4MPEg@mail.gmail.com>
Subject: Re: [PATCH v20 00/23] Richacls (Core and Ext4)
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Steve French <smfrench@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 18, 2016 at 6:20 AM, Steve French <smfrench@gmail.com> wrote:
> Reviewing the current version of your patch series in your tree
>  git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git \
>         richacl-2016-03-16
>
> you can add my reviewed by to the following patches so far:

Done, thanks.

Andreas
