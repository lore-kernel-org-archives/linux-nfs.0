From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/6] NLM: Initialize completion variable in lockd_up
Date: Sat, 15 Mar 2008 02:34:03 -0400
Message-ID: <20080315063403.GA6942@infradead.org>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com> <1199820798-5289-2-git-send-email-jlayton@redhat.com> <1199820798-5289-3-git-send-email-jlayton@redhat.com> <1199820798-5289-4-git-send-email-jlayton@redhat.com> <20080109173542.GA30523@infradead.org> <20080113082718.396890f7@tleilax.poochiereds.net> <20080113181743.GA20219@infradead.org> <170fa0d20803142044i3e4d134fq5b287134248a113f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Jeff Layton <jlayton@redhat.com>, akpm@linux-foundation.org,
	neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:48933 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbYCOGej (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Mar 2008 02:34:39 -0400
In-Reply-To: <170fa0d20803142044i3e4d134fq5b287134248a113f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 14, 2008 at 10:44:31PM -0500, Mike Snitzer wrote:
> On Sun, Jan 13, 2008 at 1:17 PM, Christoph Hellwig <hch@infradead.org> wrote:
> >  Btw, lockd() takes BKL just after starting up and only implicitly drops
> >  it when blocking.  This seems very dangerous to me and badly wants
> >  updating to some real locking scheme..
> 
> Can you elaborate on what is meant by lockd "blocking"?  Blocking in
> svc_recv() or during a SETLKW or ???

Blocking in kernel context means sleeping aka scheduling away.  So in the
sentence above that means BKL is dropped once lockd sleeps on a
syncronization primitive the first time.

