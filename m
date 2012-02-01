Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61931 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932287Ab2BATs0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 14:48:26 -0500
Received: by wgbdt10 with SMTP id dt10so1700155wgb.1
        for <linux-nfs@vger.kernel.org>; Wed, 01 Feb 2012 11:48:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <558BFA3B-5519-4224-83F3-6DEAB35310C0@oracle.com>
References: <1324602327-1789-1-git-send-email-teg@jklm.no> <1328096830-1383-1-git-send-email-teg@jklm.no>
 <22B77A95-49D5-4855-A230-A86C57372B28@oracle.com> <CAG-2HqVC3k+vmO2ieARqrKFEuP1RWZmBZ63J088DvBzSh2EdMA@mail.gmail.com>
 <558BFA3B-5519-4224-83F3-6DEAB35310C0@oracle.com>
From: Tom Gundersen <teg@jklm.no>
Date: Wed, 1 Feb 2012 20:48:05 +0100
Message-ID: <CAG-2HqUcTn9UEDFY8_Rum2Z48GVD5wWV94KcZY6R+UVAWR_R6w@mail.gmail.com>
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Lennart Poettering <lennart@poettering.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Michal Schmidt <mschmidt@redhat.com>,
        Steve Dickson <steved@redhat.com>, systemd-devel@lists.freedesktop.org,
        libtirpc <libtirpc-devel@lists.sourceforge.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 1, 2012 at 7:16 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Submit the patch you have below, then white space fixes become subsequent clean up patches.  Not only is review easier now, but if we come back to these changes in a year to fix bugs, it's easier for us to re-learn what it does.

I'll resubmit as two patches (one only doing indentation). Though,
I'll wait a ittle while in case there is more feedback.

> I'll state the question differently: When the SYSTEMD macro is defined, what kind of tests should we run? In general, how do we confirm this is working as expected?  (There may be no good answer at the moment).

In general the patch is meant to achieve two things:

1) If not using systemd, everything should work as before, even if the
SYSTEMD macro is defined.

2) When using systemd, enabling rpcbind.socket should cause rpcbind to
start on demand and act as if it was running all along. Anything that
used to be "After=rpcbind.service" should simply be
"After=rpcbind.socket" (or more generally: "After=rpcbind.target",
which in turn is "After=rpcbind.socket").

Cheers,

Tom
