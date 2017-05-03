Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56862 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753414AbdECUNK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 16:13:10 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <87shkl3fni.fsf@rasmusvillemoes.dk>
References: <87shkl3fni.fsf@rasmusvillemoes.dk> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382748241.30481.12971647975706869540.stgit@warthog.procyon.org.uk>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Subject: Re: [PATCH 1/9] Provide a function to create a NUL-terminated string from unterminated data
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 03 May 2017 21:13:07 +0100
Message-ID: <6062.1493842387@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:

> > Provide a function, kstrcreate()
> 
> <bikeshed>why not kmemdup_nul, since it seems to be to kmemdup exactly as
> memdup_user_nul is to memdup_user?</bikeshed> 

Yeah, that would work too.  Or kmem2str().

David
