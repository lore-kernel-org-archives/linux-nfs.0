Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0048.hostedemail.com ([216.40.44.48]:57937 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753831AbdEDOeq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 May 2017 10:34:46 -0400
Message-ID: <1493908479.22125.33.camel@perches.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
From: Joe Perches <joe@perches.com>
To: David Howells <dhowells@redhat.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Date: Thu, 04 May 2017 07:34:39 -0700
In-Reply-To: <16293.1493890025@warthog.procyon.org.uk>
References: <1493835998.22125.15.camel@perches.com>
         <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
         <1493835238.3180.7.camel@poochiereds.net>
         <16293.1493890025@warthog.procyon.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-05-04 at 10:27 +0100, David Howells wrote:
> Joe Perches <joe@perches.com> wrote:
> 
> > krealloc would probably be more efficient and possible
> > readable as likely there's already padding in the original
> > allocation.
> 
> Given there's a maximum of 3 slots, I think it makes better sense to just
> allocate them all up front.

Sounds good to me.
Simpler is frequently better.

