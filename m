Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw1-f68.google.com ([209.85.161.68]:43610 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727738AbeJTCFh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 22:05:37 -0400
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <CAOQ4uxjN8-SsGN6M0fL-NM1X5EmxXPD7UEYjimiAOh95WoT5oA@mail.gmail.com>
 <CAOQ4uxg=Y784nrkYmqMpOKtQD9y9ZFk+SavXtuGp-KFTSf4rAQ@mail.gmail.com> <20181019174446.GA28891@bombadil.infradead.org>
In-Reply-To: <20181019174446.GA28891@bombadil.infradead.org>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 19 Oct 2018 20:58:17 +0300
Message-ID: <CAOQ4uxgCp6aF_Ga6T=T7iNQHeR6KZfwEPvbURh9uXYZtyRjEtw@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To: Matthew Wilcox <willy@infradead.org>
Cc: olga.kornievskaia@gmail.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        fweimer@redhat.com, Steve French <smfrench@gmail.com>,
        linux-api@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 19, 2018 at 8:44 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Oct 19, 2018 at 07:14:23PM +0300, Amir Goldstein wrote:
> > > On Fri, Oct 19, 2018 at 6:30 PM Olga Kornievskaia
> > > <olga.kornievskaia@gmail.com> wrote:
> > > > Allow copy_file_range to copy between different superblocks but only
> > > > of the same file system types. This feature was of interest to CIFS
> > > > as well as NFS.
> >
> > Sorry, you meant to allow cross sb copy from client, so you do want
> > to change user facing behavior.
> > For that you need to declare a flag to opt in for the new behavior
> > and document it.
> > Please keep linux-api CC-ed when posting the flag.
> > Referencing a draft for man page is recommended.
>
> Huh?  We're allowed to make things work that used to fail.  There's no
> need to add a flag that the user must set.

OK, you are right. Maybe this case doesn't call for an opt-in flag.
I'll let other people weight in.
I should note that the behavior of copy_file_range() has already
changed silently to try to clone_file_range() first and that went
quietly...

Thanks,
Amir.
