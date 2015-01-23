Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:51275 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754267AbbAWNlx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2015 08:41:53 -0500
Date: Fri, 23 Jan 2015 14:41:50 +0100
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Race in bl_resolve_deviceid?
Message-ID: <20150123134150.GA28155@lst.de>
References: <CAHQdGtTqYi0krW6b9w0Bxe-UJkP1nPZEJdCEMYb5XTA91rBtLw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTqYi0krW6b9w0Bxe-UJkP1nPZEJdCEMYb5XTA91rBtLw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 14, 2015 at 11:51:37AM -0500, Trond Myklebust wrote:
> Doesn't that call to 'set_current_state()' need to come before the
> rpc_queue_upcall() if you want the wait for the downcall to be
> race-free? It looks to me as if the right thing to do here is to
> replace the above with a prepare_to_wait()/finish_wait() pair...

After the trivial switch to prepare_to_wait()/finish_wait() the
thread asking for the deviceid never gets woken.  I'll need more
time to understand all the code around the rpc_pipefs upcalls.
