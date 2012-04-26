Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44929 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032Ab2DZV6j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 17:58:39 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1335460011.9701.30.camel@lade.trondhjem.org>
References: <1335460011.9701.30.camel@lade.trondhjem.org> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <CAH2r5ms4WQV3DnTvqNN=2N71Cj8UHwj8Z6+RHXgrAOv6mSoyQg@mail.gmail.com> <20656.1335450358@redhat.com> <CAH2r5mv1Lijdwk5zsQwYJr4Etb6fhrRyNXm-iFCQX+HecboGrQ@mail.gmail.com> <1335453958.9701.10.camel@lade.trondhjem.org> <CAH2r5mt5af-_hxBRKK72iD5Gr99bo91ec78Rov8EGVEx8=21mA@mail.gmail.com> <1335459642.9701.27.camel@lade.trondhjem.org> <CAH2r5mvmCfLrxRHje6Wx5X84zxPEHwRMUJGsjvWBujMu7w841w@mail.gmail.com> 
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: dhowells@redhat.com, Steve French <smfrench@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "wine-devel@winehq.org" <wine-devel@winehq.org>,
        "kfm-devel@kde.org" <kfm-devel@kde.org>,
        "nautilus-list@gnome.org" <nautilus-list@gnome.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
        "libc-alpha@sourceware.org" <libc-alpha@sourceware.org>
Subject: Re: [PATCH 0/6] Extended file stat system call
Date: Thu, 26 Apr 2012 22:57:56 +0100
Message-ID: <10104.1335477476@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> You are still not explaining why they need to know the values at all? If
> the values are bogus, then don't return them, and don't set the flag
> that says they are being returned.

What if the xstat() and struct xstat eventually becomes what userspace uses as
stat() (as a wrapper) and struct stat (if such a thing is possible with glibc
versioning)?  Do older programs that think they're using stat() and don't know
about the extra fields available expect to see a useful value in st_ino?

David
