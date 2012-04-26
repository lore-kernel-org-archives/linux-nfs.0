Return-Path: linux-nfs-owner@vger.kernel.org
Received: from toast.topped-with-meat.com ([204.197.218.159]:54051 "EHLO
	topped-with-meat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758866Ab2DZWFx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 18:05:53 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: Roland McGrath <roland@hack.frob.com>
To: David Howells <dhowells@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Steve French <smfrench@gmail.com>,
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
In-Reply-To: David Howells's message of  Thursday, 26 April 2012 22:57:56 +0100 <10104.1335477476@redhat.com>
References: <1335460011.9701.30.camel@lade.trondhjem.org>
	<20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<CAH2r5ms4WQV3DnTvqNN=2N71Cj8UHwj8Z6+RHXgrAOv6mSoyQg@mail.gmail.com>
	<20656.1335450358@redhat.com>
	<CAH2r5mv1Lijdwk5zsQwYJr4Etb6fhrRyNXm-iFCQX+HecboGrQ@mail.gmail.com>
	<1335453958.9701.10.camel@lade.trondhjem.org>
	<CAH2r5mt5af-_hxBRKK72iD5Gr99bo91ec78Rov8EGVEx8=21mA@mail.gmail.com>
	<1335459642.9701.27.camel@lade.trondhjem.org>
	<CAH2r5mvmCfLrxRHje6Wx5X84zxPEHwRMUJGsjvWBujMu7w841w@mail.gmail.com>
	<10104.1335477476@redhat.com>
Message-Id: <20120426220552.D98D62C0D3@topped-with-meat.com>
Date: Thu, 26 Apr 2012 15:05:52 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> What if the xstat() and struct xstat eventually becomes what userspace
> uses as stat() (as a wrapper) and struct stat (if such a thing is
> possible with glibc versioning)?  

It's certainly possible with symbol versioning, though it seems much more
likely that we'd stick with the existing struct stat and stat* interfaces
and only have the implementation using statx underneath (e.g. for new
machines or kernel ABIs where the kernel stops providing any calls except
for statxat), at least for the foreseeable future.

> Do older programs that think they're using stat() and don't know about
> the extra fields available expect to see a useful value in st_ino?

POSIX requires that st_ino have a useful value for the standard *stat calls.


Thanks,
Roland
