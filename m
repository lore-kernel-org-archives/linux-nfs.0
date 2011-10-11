Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:47671 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab1JKGTb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Oct 2011 02:19:31 -0400
Date: Tue, 11 Oct 2011 08:19:23 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@netapp.com, smfrench@gmail.com, rjw@sisk.pl,
        linux-pm@lists.linux-foundation.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, john@Calva.COM,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] sunrpc: make rpc_wait_bit_killable handle freeze
 events
Message-ID: <20111011061923.GC1377@ucw.cz>
References: <1317210761-11518-1-git-send-email-jlayton@redhat.com>
 <1317210761-11518-4-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1317210761-11518-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 2011-09-28 07:52:40, Jeff Layton wrote:
> Allow the wait_on_bit_killable sleeps in SUNRPC layer to respect the
> freezer. This should allow suspend and hibernate events to occur, even
> when there are RPC's pending on the wire.

Will the RPC protocols used handle that correctly? What will happen
during resume?

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
