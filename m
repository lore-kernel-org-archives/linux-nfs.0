Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44214 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756027AbbJHNAJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 09:00:09 -0400
Date: Thu, 8 Oct 2015 09:00:08 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Use MSG_SENDPAGE_NOTLAST when calling sendpage()
Message-ID: <20151008130008.GB32078@fieldses.org>
References: <1444240482-11287-1-git-send-email-trond.myklebust@primarydata.com>
 <20151007200831.GB27924@fieldses.org>
 <CAHQdGtQT8+LeKyPghb9Ypr0kyF4aNXSOHCNDc3fvhZETvrpxLg@mail.gmail.com>
 <CAHQdGtR-voskykC+UkdxQ0+7gp-qm4yUXHjfzwDKZ9aRhrk2-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtR-voskykC+UkdxQ0+7gp-qm4yUXHjfzwDKZ9aRhrk2-Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 08, 2015 at 08:35:02AM -0400, Trond Myklebust wrote:
> On Wed, Oct 7, 2015 at 7:17 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> > On Wed, Oct 7, 2015 at 4:08 PM, Bruce Fields <bfields@fieldses.org> wrote:
> >> On Wed, Oct 07, 2015 at 01:54:42PM -0400, Trond Myklebust wrote:
> >>> If we're sending more pages via kernel_sendpage(), then set
> >>> MSG_SENDPAGE_NOTLAST.
> >>
> >> Given that we've survived without this a while, I assume this is a hint
> >> that may provide better performance in some cases (have you seen that?)
> >> and that it doesn't have to be 100% correct?
> >
> > See the original motivation in:
> >
> > commit 2f5338442425 ("tcp: allow splice() to build full TSO packets")
> >
> > and the later bugfix (which actually introduces MSG_SENDPAGE_NOTLAST):
> >
> > commit 35f9c09fe9c7 ("tcp: tcp_sendpages() should call tcp_push() once")
> >
> >> In which case, looks fine, will queue up for 4.4....
> >
> > Sure. It's a minor performance enhancement, so there is no immediate rush.
> 
> Actually, please let me split this into 2 subpatches; one for the
> sunrpc server code and one for the client. It would make it easier for
> me if I could keep the client performance stuff in one branch.

Sure, makes sense.--b.
