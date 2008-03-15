From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [PATCH 3/6] NLM: Initialize completion variable in lockd_up
Date: Fri, 14 Mar 2008 22:44:31 -0500
Message-ID: <170fa0d20803142044i3e4d134fq5b287134248a113f@mail.gmail.com>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com>
	 <1199820798-5289-2-git-send-email-jlayton@redhat.com>
	 <1199820798-5289-3-git-send-email-jlayton@redhat.com>
	 <1199820798-5289-4-git-send-email-jlayton@redhat.com>
	 <20080109173542.GA30523@infradead.org>
	 <20080113082718.396890f7@tleilax.poochiereds.net>
	 <20080113181743.GA20219@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Jeff Layton" <jlayton@redhat.com>, akpm@linux-foundation.org,
	neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Christoph Hellwig" <hch@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753684AbYCODoo@vger.kernel.org>
In-Reply-To: <20080113181743.GA20219@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 13, 2008 at 1:17 PM, Christoph Hellwig <hch@infradead.org> wrote:
>  Btw, lockd() takes BKL just after starting up and only implicitly drops
>  it when blocking.  This seems very dangerous to me and badly wants
>  updating to some real locking scheme..

Can you elaborate on what is meant by lockd "blocking"?  Blocking in
svc_recv() or during a SETLKW or ???

I'm trying to come to terms with why nlmsvc_lock() wouldn't have the
BKL on entry.
