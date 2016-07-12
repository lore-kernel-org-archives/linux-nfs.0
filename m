Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:33881 "EHLO
	mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbcGLU2Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jul 2016 16:28:16 -0400
Received: by mail-vk0-f48.google.com with SMTP id o63so38510396vkg.1
        for <linux-nfs@vger.kernel.org>; Tue, 12 Jul 2016 13:28:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160712191142.GE449@fieldses.org>
References: <1467294433-3222-1-git-send-email-agruenba@redhat.com>
 <1467294433-3222-18-git-send-email-agruenba@redhat.com> <1468324560.7798.14.camel@redhat.com>
 <20160712191142.GE449@fieldses.org>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 12 Jul 2016 22:28:15 +0200
Message-ID: <CAHc6FU6k+eZ1Ozc8wofDBNOAHZzvXXWMAs1NJNTbd9Ntbqqsqw@mail.gmail.com>
Subject: Re: [PATCH v23 17/22] richacl: Automatic Inheritance
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
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

On Tue, Jul 12, 2016 at 9:11 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Jul 12, 2016 at 07:56:00AM -0400, Jeff Layton wrote:
>> Barf. AI seems like a trainwreck waiting to happen. What are the
>> chances that userland is going to get this right?
>
> This is just taken from Windows, so presumably Samba should do the right
> thing (with one workaround required--see the discussion of PROTECTED in
> the changelog).
>
>> Still, I do applaud the fact that you're just doing the bare minimum in
>> kernel to support userland apps that want this. Thanks for not trying
>> to push the propagation of the changed ACEs into the kernel.
>
> Agreed.  But, again, this is just what Windows does.  (I wonder whether
> there's an OS that's actually tried do any sort of atomic propagation.)

NetWare's NSS filesystem did have automatic propagation, but I think
that was implemented by composing the permissions along the path to a
file at access time.

Andreas
