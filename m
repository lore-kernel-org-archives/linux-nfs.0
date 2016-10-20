Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41910 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964884AbcJTPwc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Oct 2016 11:52:32 -0400
Date: Thu, 20 Oct 2016 11:52:31 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH] nfsd: more robust allocation failure handling in
 nfsd_reply_cache_init
Message-ID: <20161020155231.GA4347@fieldses.org>
References: <1472557703-5985-1-git-send-email-jlayton@redhat.com>
 <CA+55aFzVnBqtk5Az3VNMQ=HfTUBSYyOVejHykU2c63K70s24=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFzVnBqtk5Az3VNMQ=HfTUBSYyOVejHykU2c63K70s24=A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 30, 2016 at 11:23:36AM -0700, Linus Torvalds wrote:
> On Tue, Aug 30, 2016 at 4:48 AM, Jeff Layton <jlayton@redhat.com> wrote:
> >
> > While this would be good to get in, I don't see any particular urgency
> > here. This seems like it'd be reasonable for v4.9.
> 
> Agreed, looks ok to me. It certainly does not look like a new
> regression or like a serious problem issue in practice. So 4.9 sounds
> appropriate.

Gah, Jeff points out I forgot to merge this.

Jeff was also wondering whether we could instead just allocate this with
vmalloc--is there any drawback?  We only allocate this on nfsd startup,
so if the only drawback is the allocation itself being expensive then
that's no big deal.

--b.
