Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gardel.0pointer.net ([85.214.157.71]:42744 "EHLO
        gardel.0pointer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751959AbdBFUsC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2017 15:48:02 -0500
Date: Mon, 6 Feb 2017 21:38:13 +0100
From: Lennart Poettering <lennart@poettering.net>
To: NeilBrown <neilb@suse.com>
Cc: systemd-devel@freedesktop.org,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [systemd-devel] RequiresMountsFor and the noauto option.
Message-ID: <20170206203813.GA20905@gardel-login>
References: <87inp6eipr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87inp6eipr.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23.01.17 11:13, NeilBrown (neilb@suse.com) wrote:

> 
> hi,
>  according to "man systemd.unit" :
> 
>        RequiresMountsFor=
>            Takes a space-separated list of absolute paths.
>            Automatically adds dependencies of type Requires= and
>            After= for all mount units required to access the
>            specified path.
> 
>            Mount points marked with noauto are not mounted
>            automatically and will be ignored for the purposes of
>            this option. If such a mount should be a requirement for
>            this unit, direct dependencies on the mount units may be
>            added (Requires= and After= or some other combination).

Hmm, this is weird. This is actually not what happens. The
documentaiton is simply not correct here. That's a bug we need to
fix. I filed a bug about this now:

https://github.com/systemd/systemd/issues/5249

What actually happens is that RMF= adds After= for all prefix mount
units, but Requires= only to those which have a fragment file
(i.e. are explicitly configured). The "noauto" flag is not checked.

Sorry for the confusion.

>  If the documentation is wrong, and the code is correct, would it be
>  possible to get "AfterMountsFor=" as that is the functionality that I
>  really want.

I figure we could add that. Please file an RFE on github.

Lennart

-- 
Lennart Poettering, Red Hat
