Return-Path: linux-nfs-owner@vger.kernel.org
Received: from toast.topped-with-meat.com ([204.197.218.159]:50239 "EHLO
	topped-with-meat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426Ab2DZSYD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 14:24:03 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: Roland McGrath <roland@hack.frob.com>
To: David Howells <dhowells@redhat.com>
Cc: Paul Eggert <eggert@cs.ucla.edu>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
In-Reply-To: David Howells's message of  Thursday, 26 April 2012 15:04:07 +0100 <19638.1335449047@redhat.com>
References: <4F9088D6.9020203@cs.ucla.edu>
	<20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<20120419163238.61D382C0DF@topped-with-meat.com>
	<19638.1335449047@redhat.com>
Message-Id: <20120426182401.B246E2C0EA@topped-with-meat.com>
Date: Thu, 26 Apr 2012 11:24:01 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Interesting.  I wasn't intending to provide both statx() and statxat()
> variants, just the latter, in which case I'd've though that -at suffix is
> redundant.

It's certainly fine to provide only *at flavors for any new syscall, IMHO.
The * case is always just a simple degenerate case of *at, and libc can
trivially provide the simpler user API as well using the *at syscall.

But please keep the uniformity that everything taking a descriptor and AT_*
flags is named *at.


Thanks,
Roland
