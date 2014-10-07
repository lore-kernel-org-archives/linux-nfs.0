Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:48284 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942AbaJGSC2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Oct 2014 14:02:28 -0400
Received: by mail-vc0-f182.google.com with SMTP id la4so5186463vcb.41
        for <linux-nfs@vger.kernel.org>; Tue, 07 Oct 2014 11:02:27 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 7 Oct 2014 14:02:25 -0400
To: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 02/17] security: make security_file_set_fowner,
 f_setown and __f_setown void return
Message-ID: <20141007140225.22301447@synchrony.poochiereds.net>
In-Reply-To: <CACE9dm_NKwFV__MeQw039yenbjzT+XwakgxZuynr25EVWHjRdQ@mail.gmail.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-3-git-send-email-jlayton@primarydata.com>
	<CACE9dm-gEfVnHvESfewAPx1vDSdpUW+za=H_zpA8hJd55AR=tA@mail.gmail.com>
	<20141007171703.GA30274@infradead.org>
	<CACE9dm_NKwFV__MeQw039yenbjzT+XwakgxZuynr25EVWHjRdQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 7 Oct 2014 20:34:57 +0300
Dmitry Kasatkin <dmitry.kasatkin@gmail.com> wrote:

> On 7 October 2014 20:17, Christoph Hellwig <hch@infradead.org> wrote:
> > On Tue, Oct 07, 2014 at 08:11:42PM +0300, Dmitry Kasatkin wrote:
> >> If file_set_fowner op is now type of "void", how you can actually
> >> return the value?
> >> I think compiler must give error. How could you compile it?
> >
> > Returning void values is a GNU extension.  I've seen it in a few
> > places in the kernel.  Although in general I'd prefer it we'd remove
> > it (and have the compiler warn about it).
> >
> 
> Cool. There were patches around to use LLVM as well.
> Will it work there?
> 

Well, no one has complained so far, and this has been in linux-next for
more than a month or so. I was just getting ready to send my pull
request to Linus, so you caught this just in time.

I'll respin this patch to not call "return" there and let it stew in
-next for a couple of days before I send the pull request.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
