Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33566 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387654AbeHANZm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Aug 2018 09:25:42 -0400
Date: Wed, 1 Aug 2018 07:40:19 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>,
        Eddie Horng <eddiehorng.tw@gmail.com>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: fix leaked file lock with nfs exported overlayfs
Message-ID: <20180801114019.GA15798@fieldses.org>
References: <1531491744-13277-1-git-send-email-amir73il@gmail.com>
 <8fc65417ebda26a198e01e8c82f41ae08ab3c803.camel@kernel.org>
 <CAOQ4uxhvLVLLh_DyXp4q27NNo-+55tbdHOCu3=p8pNin66vv-g@mail.gmail.com>
 <CAJfpegtyTnYdqYmwG5Jqn6rhDMhjdrkOO5Ziu91f5E+sEgyZoQ@mail.gmail.com>
 <CAOQ4uxg+kuAuZ=o7U+77mrYO5zkFAGCkNpiZSVDdYKcdm631_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAOQ4uxg+kuAuZ=o7U+77mrYO5zkFAGCkNpiZSVDdYKcdm631_w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 01, 2018 at 09:18:24AM +0300, Amir Goldstein wrote:
> On Tue, Jul 17, 2018 at 5:24 PM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> > Needs a Cc: stable@... tag then.
> >
> > Should I take this patch (based on the fact that it only affects
> > overlayfs exports)?
> >
> > Or will you take it, Bruce?
> >
> 
> Bruce? Jeff?
> 
> It's probably a good time for someone to put this patch in -next.
> 
> Should Miklos do it?

I'm applying it, thanks for the reminder.  (Or I'd be OK with Miklos
taking it.)

--b.
