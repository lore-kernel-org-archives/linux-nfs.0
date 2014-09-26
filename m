Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:60547 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754448AbaIZQmA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 12:42:00 -0400
Date: Fri, 26 Sep 2014 18:41:58 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs/blocklayout: serialize GETDEVICEINFO calls
Message-ID: <20140926164158.GA27296@lst.de>
References: <1411740170-18611-1-git-send-email-hch@lst.de> <1411740170-18611-2-git-send-email-hch@lst.de> <CAHQdGtTg8Tc8bRqbezW-ZWrcTJdG233uRTrqQMP5CvxAcjW9Fg@mail.gmail.com> <20140926154843.GA22675@lst.de> <CAHQdGtRYN_L4ONFU5-GW3=kJ1oz5HS_7kmsn=GWCCGTgBODQAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRYN_L4ONFU5-GW3=kJ1oz5HS_7kmsn=GWCCGTgBODQAA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2014 at 12:21:06PM -0400, Trond Myklebust wrote:
> > Not without getting rid of the rpc_pipefs interface.  That is on my
> > very long term TODO list, but it will require new userspace support.
> 
> Why is that? rpc_pipefs was designed to be message based, so it should
> work quite well in a multi-threaded environment. We certainly don't
> use mutexes around the gssd up/downcall, and the only reason for the
> mutex in idmapd is to deal with the keyring upcall.

Ok, the GSS code dynamically allocates a new message for each upcall
and thus doesn't have the issue.  I'll take a look if I can do this
in the blocklayout driver as well.
