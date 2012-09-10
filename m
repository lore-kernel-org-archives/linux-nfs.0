Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:52268 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758403Ab2IJT6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Sep 2012 15:58:11 -0400
Date: Mon, 10 Sep 2012 15:56:50 -0400
From: Jim Rees <rees@umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: andros@netapp.com, trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] RFC Avoid expired credential keys for buffered writes
Message-ID: <20120910195650.GA3095@umich.edu>
References: <1346961251-2554-1-git-send-email-andros@netapp.com>
 <20120910145732.4d800f5b@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120910145732.4d800f5b@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:

  My only concern is this behavior described in the last patch:
  
  "If the buffered WRITE is using a credential key that will expire
  within low watermark seconds, fail the WRITE in nfs_write_begin
  _before_ the WRITE is buffered and return -EACCES to the application."
  
  Shouldn't rejecting the write attempt be the purview of the server?
  
  It seems to me that we'd be best off just switching to synchronous
  writes when we start approaching credential expiration, and letting the
  server handle the case where the credential expires.
  
  It seems to me that the client should just be in the business of
  recognizing when the credential might be about to expire and attempt to
  ensure that we don't end up with a bunch of buffered data in that case.

I don't like it.  It's easy to understand why writes might fail if the creds
are getting stale.  It's not so easy to understand why client behavior
changes in a subtle way, with performance implications.
