Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:58050 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318Ab1DKRpS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Apr 2011 13:45:18 -0400
Message-ID: <4DA33E1E.701@parallels.com>
Date: Mon, 11 Apr 2011 12:45:02 -0500
From: Rob Landley <rlandley@parallels.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
CC: "Serge E. Hallyn" <serge@hallyn.com>, <linux-kernel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <containers@lists.linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Tim Spriggs <tims@uahirise.org>, Kir Kolyshkin <kir@parallels.com>,
        Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 3/3] Compare namespaces when comparing addresses in auth_unix
 cache.
References: <4D9431B3.2070305@parallels.com>	<20110405034641.GC6764@hallyn.com>	<4D9F24F2.9020603@parallels.com>	<4DA30222.5040902@parallels.com>	<20110411133602.GA5321@hallyn.com> <BANLkTi=sh1CB+e1EhU-c-Bs3BCszWEBTMA@mail.gmail.com>
In-Reply-To: <BANLkTi=sh1CB+e1EhU-c-Bs3BCszWEBTMA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/11/2011 08:57 AM, Alexey Dobriyan wrote:
> On Mon, Apr 11, 2011 at 4:36 PM, Serge E. Hallyn <serge@hallyn.com> wrote:
> 
>> Besides use-after-free, the other concern is an invalid net_eq()
>> result due to the * being re-used for a new netns.
> 
> Exactly.
> 
> "struct net" dies last, no exceptions, anything different is a disaster.

Actually the patch turns out to be irrelevant because Pavel made the
whole thing into a pernet subsystem, so it was already fixed in a
different way.  (Commit 2f72c9b7.  My bad, I initially started working
against an NFS tree with an older kernel version, this fix was to a
different source file so my patch still applied, and I just regression
tested that it worked, not that it still failed without it.  Just caught
it now.)

I actually did talk about addressing potential reuse of the net * in my
email with Stanislav (point of the patch was to allow one cache to
maintain two different contexts at the same time; a situation that
changed the meaning of an existing cache entry by requiring the old
context to go away didn't introduce any new problems that a single
context didn't already have due to DNAT, servers moving, administrators
changing credentials on the server).  But sort of a moot point now.

I believe the third patch can be dropped entirely.

Rob
