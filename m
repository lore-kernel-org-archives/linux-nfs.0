Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57013 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069AbaEWNfj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 09:35:39 -0400
Date: Fri, 23 May 2014 09:35:37 -0400
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com, NeilBrown <neilb@suse.de>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: NFS issue while copying huge file
Message-ID: <20140523133537.GI25423@fieldses.org>
References: <CAFLxGvw_7=AuBqxNhAHpQAXq2aTqc8Afa6Z62=YCsFXcJx0Hug@mail.gmail.com>
 <CAFLxGvxm43MaOqv1JQ8vxkn4s50uHZ8Js6A-Ec+O_sjvFszehQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAFLxGvxm43MaOqv1JQ8vxkn4s50uHZ8Js6A-Ec+O_sjvFszehQ@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 22, 2014 at 12:50:34PM +0200, Richard Weinberger wrote:
> On Wed, May 21, 2014 at 11:33 PM, Richard Weinberger
> <richard.weinberger@gmail.com> wrote:
> > Hi!
> >
> > My backup server runs CentOS6 with kernel 2.6.32-431.17.1.el6.x86_64.
> > Many servers copy theirs backups to it. This setups works perfectly
> > fine since ages.
> > Today I've configured a new server which runs Kernel 3.12.20 to store
> > it's backups to the NFS server too.
...
> Just gave 3.15-rc6 a try, it happens here too.

I was reading a little quickly and assumed all these kernel versions
described the NFS server, now I understand you're varying only the NFS
client; so against that CentOS 2.6.32 server, you're seeing the problem
when the NFS client is 3.12.20 or 3.15-rc6, but not if the NFS client is
running the same CentOS 2.6.32 version.  Got it, sorry for the
confusion.

So with my upstream hat on that's a little less interesting since
upstream is pretty far from any 2.6.32-based kernel at this point.

--b.
