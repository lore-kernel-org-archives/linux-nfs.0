Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41109 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932691AbaLJVHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 16:07:24 -0500
Date: Wed, 10 Dec 2014 16:07:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: David =?utf-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>
Cc: linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141210210723.GG20235@fieldses.org>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
 <20141210203511.GF20235@fieldses.org>
 <20141210204917.GA11396@hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20141210204917.GA11396@hardeman.nu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 10, 2014 at 09:49:17PM +0100, David Härdeman wrote:
> On Wed, Dec 10, 2014 at 03:35:11PM -0500, J. Bruce Fields wrote:
> >On Tue, Dec 09, 2014 at 06:40:40AM +0100, David Härdeman wrote:
> >> The following series converts gssd to use libevent and inotify instead
> >> of a handrolled event loop and dnotify. Lots of cleanups in the process
> >> (e.g. removing a lot of arbitrary limitations and fixed size buffers).
> >> 
> >> All in all a nice reduction in code size (what can I say, I was bored).
> >
> >This code has been crying out for help for a while, thanks for taking a
> >look!
> 
> :)
> 
> >On dnotify/inotify: if I remember correctly, this was written before
> >inotify existed.  So you're probably breaking compatibility with older
> >kernels, which we normally try not to do.
> 
> Fair enough...but...there has to be some kind of reasonable limit to
> that. Like...unmaintained kernel versions with known CVEs...if an
> organization is *that* conservative...I kinda doubt they'd update
> nfs-utils either?

Personally I worry more about troubleshooting: RHEL4 user runs into nfs
problem that looks like something we fixed in recent nfs-utils, we might
like to be able to tell them just to try latest nfs-utils....

But at this point I think that's unlikely.

> >According to inotify(7):
> >
> >	Inotify  was merged into the 2.6.13 Linux kernel.  The required
> >	library interfaces were  added  to  glibc  in  version  2.4.
> >	(IN_DONT_FOLLOW, IN_MASK_ADD, and IN_ONLYDIR were added in
> >	version 2.5.)
> >
> >So that's almost 10 years.  In RHEL terms I think RHEL4 would be the
> >latest without inotify support.
> >
> >OK, maybe that's long enough.
> 
> I should add that krb5 support was added on 13 January 2003,
> (commit e0594725b51b5253237ed11b8bf3cf9ab87d9d48)
> which corresponds to kernel version 2.5.57 or .58.
> 
> 2.6.13 is from 29 August, 2005....so we'd kill support for that time
> span...
> 
> >If there's an easy way to provide a fallback to dnotify, that would be
> >nice
> 
> I think you and I have different ideas of the definition of the word
> "nice" :)
>
> >otherwise would you mind just adding a note about this somewhere?
> >(Maybe the gssd man page should say something like "this version of gssd
> >depends on inotify, introduced in kernel version 2.6.13...".)
> 
> I could add that in a separate patch...both to the changelog and the man
> page. 

That'd be fine, thanks.--b.
