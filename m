Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12100 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165Ab1GKUMz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2011 16:12:55 -0400
Subject: Re: [PATCH 2/2] NFS: Send SIGIO on lost locks
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bjschuma@netapp.com, linux-nfs@vger.kernel.org
Date: Mon, 11 Jul 2011 16:12:24 -0400
In-Reply-To: <20110711160851.13814fa1@tlielax.poochiereds.net>
References: <1310407110-20600-1-git-send-email-bjschuma@netapp.com>
	 <1310407110-20600-2-git-send-email-bjschuma@netapp.com>
	 <20110711160851.13814fa1@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1310415144.12660.32.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-07-11 at 16:08 -0400, Jeff Layton wrote: 
> On Mon, 11 Jul 2011 13:58:30 -0400
> bjschuma@netapp.com wrote:
> 
> > From: Bryan Schumaker <bjschuma@netapp.com>
> > 
> > If the client loses a lock, we send SIGIO to the application to notify
> > it.  The application can then handle the error from there.
> > 
> > Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> 
> Would SIGLOST be a better choice? Linux hasn't supported that
> historically, but we could add it.

SIGLOST is 'defined' in the kernel as follows:

#define SIGIO           29
#define SIGPOLL         SIGIO
/*
#define SIGLOST         29
*/

IOW: it is synonymous with SIGPOLL and SIGIO. This explains Bryan's
choice.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

