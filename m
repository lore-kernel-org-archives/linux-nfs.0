Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:54405 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671Ab2HCMJK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Aug 2012 08:09:10 -0400
Received: by obbuo13 with SMTP id uo13so998719obb.19
        for <linux-nfs@vger.kernel.org>; Fri, 03 Aug 2012 05:09:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <866.1343987269@warthog.procyon.org.uk>
References: <CAJ75kXa9PRJMHXfTHGLxnXUAMwnA9RD5G+cjHnOdk8SE_hbsZQ@mail.gmail.com>
 <866.1343987269@warthog.procyon.org.uk>
From: William Dauchy <wdauchy@gmail.com>
Date: Fri, 3 Aug 2012 14:08:49 +0200
Message-ID: <CAJ75kXaYgxiRZnFzZLXSj61EXOEVNsPcy70etkLRhEpy9AWDnA@mail.gmail.com>
Subject: Re: nfs_idmap_legacy_upcall
To: David Howells <dhowells@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David,

Thank you for your reply.

On Fri, Aug 3, 2012 at 11:47 AM, David Howells <dhowells@redhat.com> wrote:
> I'm afraid I'm not going to be able to do a lot with this until the 13th as
> I'm about to go on holiday.  If it is still a problem when I get back, I'll
> look at it then.

Thanks. I started to dig it and went through the huge backlog between
3.4 and 3.5. It seems like a race during mount since it's only
happening sometimes and can't reproduce it easily.
I first thought there was still an issue in this fix:
b102743: NFS: Force the legacy idmapper to be single threaded
but then found:
4697bd5:NFSv4: Fix a race in the net namespace mount notification

I guess this last one might be related to my issues since idmaper is
using struct nfs_client. I started new tests with it.

Regards,
-- 
William
