Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:57118 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933516AbaD2Luu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 07:50:50 -0400
Received: by mail-qg0-f43.google.com with SMTP id a108so78374qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Apr 2014 04:50:49 -0700 (PDT)
Date: Tue, 29 Apr 2014 07:50:46 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        lkml <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
        "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>,
        "Frank Filz" <ffilzlnx@mindspring.com>
Subject: Re: OFD ("file private") locks and NFS
Message-ID: <20140429075046.39fc9c3f@tlielax.poochiereds.net>
In-Reply-To: <1482413734.4.1398771608019.JavaMail.root@thunderbeast.private.linuxbox.com>
References: <20140429071153.176c7404@tlielax.poochiereds.net>
	<1482413734.4.1398771608019.JavaMail.root@thunderbeast.private.linuxbox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 29 Apr 2014 07:40:08 -0400 (EDT)
"Matt W. Benjamin" <matt@linuxbox.com> wrote:

> Hi Jeff,
> 
> Something which came up on the last Ganesha conn call is that we have
> a pretty strong need for some ability to wait on a set of locks, and perhaps
> receive events.  Frank Filz believed that you had made a proposal which
> would cover this.  Can you elaborate on that?
> 
> Thanks,
> 
> Matt
> 

No, there's no mechanism to wait on a set of locks from within the
context of a single thread of execution or to receive "events". Again,
that would be a new API beyond what I've been proposing over the last
several months.
-- 
Jeff Layton <jlayton@poochiereds.net>
