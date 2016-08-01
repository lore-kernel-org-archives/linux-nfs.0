Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48174 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbcHAOnu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Aug 2016 10:43:50 -0400
Date: Mon, 1 Aug 2016 10:42:56 -0400
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'J. Bruce Fields'" <bfields@redhat.com>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
Subject: Re: pynfs pull request
Message-ID: <20160801144256.GB4953@fieldses.org>
References: <037201d1e81e$04a9b9f0$0dfd2dd0$@mindspring.com>
 <20160728193855.GF4732@pad>
 <040401d1e914$52e71a30$f8b54e90$@mindspring.com>
 <20160729213011.GA11390@pad>
 <047b01d1e9e3$e6d51fb0$b47f5f10$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <047b01d1e9e3$e6d51fb0$b47f5f10$@mindspring.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > The reason knfsd gave up on the utf8 tests was complaints from people with
> > filesystems with non-utf8 encodings.  Given a preexisting filesystem
> neither
> > knfsd nor probably Ganesha has any way to determine the encoding, so
> > we're left just injecting unhelpful errors when we come across something
> > that doesn't look like utf-8.  Which just annoyed people with those
> > filesystems, didn't really help anyone else, and changed behavior on
> NFSv3-
> > >NFSv4 upgrade.
> > 
> > But maybe non-utf8 is less common now.

On Fri, Jul 29, 2016 at 02:55:19PM -0700, Frank Filz wrote:
> Hmm, I can see that point. It would be interesting to see if we could just
> lump utf8 tests into all now...

In our case we'd have to reintroduce some sort of utf8 enforcement in
knfsd, or only test with filesystems that will do that for us.  The
cases where that would cause problems are probably rarer now, but I'm
still not ready to do that.

--b.
