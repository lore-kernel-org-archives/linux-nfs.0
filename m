Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:58560 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726985AbeGRVfs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 18 Jul 2018 17:35:48 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20180718121216.GK10135@coeurl.usersys.redhat.com>
References: <20180718121216.GK10135@coeurl.usersys.redhat.com> <20180711122219.20808-1-smayhew@redhat.com> <9138.1531475067@warthog.procyon.org.uk>
To: Scott Mayhew <smayhew@redhat.com>
Cc: dhowells@redhat.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: add minor version to nfs_server_key for fscache
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 18 Jul 2018 21:56:07 +0100
Message-ID: <19765.1531947367@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Scott Mayhew <smayhew@redhat.com> wrote:

> With v4.18-rc5 plus those four patches, I no longer get the "Unexpected
> object collision" message when running cthon (and no oops either,
> obviously).

Thanks!

David
