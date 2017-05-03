Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38368 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756905AbdECT1B (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 15:27:01 -0400
Received: by mail-wm0-f42.google.com with SMTP id r190so69961261wme.1
        for <linux-nfs@vger.kernel.org>; Wed, 03 May 2017 12:27:00 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Subject: Re: [PATCH 1/9] Provide a function to create a NUL-terminated string from unterminated data
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
        <149382748241.30481.12971647975706869540.stgit@warthog.procyon.org.uk>
Date: Wed, 03 May 2017 21:26:57 +0200
In-Reply-To: <149382748241.30481.12971647975706869540.stgit@warthog.procyon.org.uk>
        (David Howells's message of "Wed, 03 May 2017 17:04:42 +0100")
Message-ID: <87shkl3fni.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 03 2017, David Howells <dhowells@redhat.com> wrote:

> Provide a function, kstrcreate()

<bikeshed>why not kmemdup_nul, since it seems to be to kmemdup exactly as
memdup_user_nul is to memdup_user?</bikeshed> 

Rasmus
