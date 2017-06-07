Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gardel.0pointer.net ([85.214.157.71]:47748 "EHLO
        gardel.0pointer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdFGIX5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jun 2017 04:23:57 -0400
Date: Wed, 7 Jun 2017 10:13:13 +0200
From: Lennart Poettering <mzxreary@0pointer.de>
To: Michael Biebl <mbiebl@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        systemd-devel@freedesktop.org, NeilBrown <neilb@suse.com>
Subject: Re: [systemd-devel] [PATCH] nfs.man: document incompatibility
 between "bg" option and systemd.
Message-ID: <20170607081313.GI27006@gardel-login>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
 <CAGWsdOjswhfUszn0AmFtFcz-sbDU8=qFr5z1=tNigROOPBS0Rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAGWsdOjswhfUszn0AmFtFcz-sbDU8=qFr5z1=tNigROOPBS0Rw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 06.06.17 21:57, Michael Biebl (mbiebl@gmail.com) wrote:

> 2017-06-06 20:07 GMT+02:00 Steve Dickson <SteveD@redhat.com>:
> > Finally, the whole idea of systemd randomly/silently
> > strip off mount options is crazy... IMHO...
> 
> Personally, I would prefer if systemd simply logged a warning/error
> message but would *not* strip the bg option.

What good does that do if "bg" doesn't actually work properly?

Lennart

-- 
Lennart Poettering, Red Hat
