Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:46739 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336Ab2DQO1E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2012 10:27:04 -0400
Received: by wgbdr13 with SMTP id dr13so6454056wgb.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 07:27:03 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "Myklebust\, Trond" <Trond.Myklebust@netapp.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach\@exagrid.com" <pstaubach@exagrid.com>,
        "viro\@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch\@infradead.org" <hch@infradead.org>,
        "michael.brantley\@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner\@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<4F8C3036.2030702@itwm.fraunhofer.de>
	<20120416134642.1754cd3e@corrin.poochiereds.net>
	<1334604785.2879.23.camel@lade.trondhjem.org>
	<20120416154322.0d95e435@corrin.poochiereds.net>
	<1334607906.2879.36.camel@lade.trondhjem.org>
	<20120416190548.2463d1d0@corrin.poochiereds.net>
	<4F8D580B.7060104@RedHat.com>
	<20120417093643.7f172057@corrin.poochiereds.net>
	<4F8D7ADF.9030709@RedHat.com>
Date: Tue, 17 Apr 2012 16:27:16 +0200
In-Reply-To: <4F8D7ADF.9030709@RedHat.com> (Steve Dickson's message of "Tue,
	17 Apr 2012 10:14:55 -0400")
Message-ID: <87k41eo2m3.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson <SteveD@redhat.com> writes:

> True, but even so... Giving file systems an opt-out option with the 
> default being out, maybe still have some merit... Making file systems
> enable this new type of functionality would cut down on any of the
> "surprise" that might occur with this redo ;-) 

I've been arguing for something slightly different for quite some time:
I never liked errno values which have side effects in the kernel yet
might be visible to userspace.

So why not introduce ERETRYSTALE, a *kernel internal* errno value that
userspace will never see and filesystems never accidentally set.  The
VFS can turn this into ESTALE if it doesn't retry for some reason
(e.g. already retried).

Thanks,
Miklos
