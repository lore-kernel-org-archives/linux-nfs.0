Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:53546 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727549AbeJTBvw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 21:51:52 -0400
Date: Fri, 19 Oct 2018 10:44:46 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: olga.kornievskaia@gmail.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        fweimer@redhat.com, Steve French <smfrench@gmail.com>,
        linux-api@vger.kernel.org
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
Message-ID: <20181019174446.GA28891@bombadil.infradead.org>
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com>
 <CAOQ4uxjN8-SsGN6M0fL-NM1X5EmxXPD7UEYjimiAOh95WoT5oA@mail.gmail.com>
 <CAOQ4uxg=Y784nrkYmqMpOKtQD9y9ZFk+SavXtuGp-KFTSf4rAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAOQ4uxg=Y784nrkYmqMpOKtQD9y9ZFk+SavXtuGp-KFTSf4rAQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 19, 2018 at 07:14:23PM +0300, Amir Goldstein wrote:
> > On Fri, Oct 19, 2018 at 6:30 PM Olga Kornievskaia
> > <olga.kornievskaia@gmail.com> wrote:
> > > Allow copy_file_range to copy between different superblocks but only
> > > of the same file system types. This feature was of interest to CIFS
> > > as well as NFS.
> 
> Sorry, you meant to allow cross sb copy from client, so you do want
> to change user facing behavior.
> For that you need to declare a flag to opt in for the new behavior
> and document it.
> Please keep linux-api CC-ed when posting the flag.
> Referencing a draft for man page is recommended.

Huh?  We're allowed to make things work that used to fail.  There's no
need to add a flag that the user must set.
