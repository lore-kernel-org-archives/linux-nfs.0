Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:50662 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932778AbeBUQtD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Feb 2018 11:49:03 -0500
Message-ID: <1519231741.7497.18.camel@redhat.com>
Subject: Re: nfs-utils: rpc.svcgssd segmentation fault in
 nss_gss_princ_to_ids()
From: Justin Mitchell <jumitche@redhat.com>
To: Matthias Gerstner <matthias.gerstner@nefkom.net>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 21 Feb 2018 16:49:01 +0000
In-Reply-To: <20180220224858.GA14972@q910.gerrit.home>
References: <20180220224858.GA14972@q910.gerrit.home>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2018-02-20 at 23:48 +0100, Matthias Gerstner wrote:
> Hello!
> 
> I hope I have found the right place to report this.
> 
> I have recently upgraded from nfs-utils-1.3.4 to nfs-utils-2.3.1 on a Gentoo
> Linux (hardened) system. After this upgrade the rpc.svcgssd crashes on my
> kerberized NFS server each time a client tries to mount an NFS export.
<snip>
>   
> I debugged this a bit and strange things came about. There seem to be
> duplicate instances of the local_realms variable in the
> support/nfsidmap/nfsidmap_common.c compilation unit:
<snip>
> So there's one instance of the variable that was actually assigned the
> expected data. And there's another one that is at NULL and returned from
> get_local_realms().
> 
> This is related to the "#pragma GCC visibility push(hidden)" in the
> compilation unit. Moving it after the local_realms variable declaration fixes
> the issue. I've attached a patch that does just this.
> 
> I am not quite sure whether this is a compiler issue or an invalid use of the
> visibility hidden pragma. The compiler used is:

This is part of my previous work to fold libnfsidmap into the nfs-utils
tree, in this case the #pragma is used to make the local_realms global
accessible only by other parts of the library that need it, external
users such as the nss plugin get access to it via the get_local_realms()
function.

I will run some tests to see if this is isolated to certain compiler
versions, or if the pragma isnt working as I expected.

However simply moving the #pragma hidden will change the ABI which is a
problem for some, so if necessary I will instead reorganise the code to
achieve the same functionality without using the pragma

