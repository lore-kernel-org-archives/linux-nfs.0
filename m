Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:52726 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292Ab2HDK1L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Aug 2012 06:27:11 -0400
Received: by pbbrp8 with SMTP id rp8so2722991pbb.19
        for <linux-nfs@vger.kernel.org>; Sat, 04 Aug 2012 03:27:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ75kXaYgxiRZnFzZLXSj61EXOEVNsPcy70etkLRhEpy9AWDnA@mail.gmail.com>
References: <CAJ75kXa9PRJMHXfTHGLxnXUAMwnA9RD5G+cjHnOdk8SE_hbsZQ@mail.gmail.com>
 <866.1343987269@warthog.procyon.org.uk> <CAJ75kXaYgxiRZnFzZLXSj61EXOEVNsPcy70etkLRhEpy9AWDnA@mail.gmail.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Sat, 4 Aug 2012 12:26:48 +0200
Message-ID: <CAJ75kXbFTm3+v9OJTcKsO+nmn6q0CbSZniT0MkP+oUh7f_sZ0Q@mail.gmail.com>
Subject: Re: nfs_idmap_legacy_upcall
To: David Howells <dhowells@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 3, 2012 at 2:08 PM, William Dauchy <wdauchy@gmail.com> wrote:
> 4697bd5:NFSv4: Fix a race in the net namespace mount notification

this one didn't help. still getting a wait_for_key_construction oops.
I opened a second thread about it, first thinking this was two
different issues
will dig it a bit more
-- 
William
