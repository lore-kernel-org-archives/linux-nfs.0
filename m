Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755120Ab2HUKlF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 06:41:05 -0400
Date: Tue, 21 Aug 2012 06:41:00 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS4ERR_DELAY (was: NFS4: ssh + unlink(~/.Xauthority) delays)
Message-ID: <20120821064100.701ec6e9@corrin.poochiereds.net>
In-Reply-To: <k0vjq7$o7l$1@ultimate100.geggus.net>
References: <k0vgkt$mm0$1@ultimate100.geggus.net>
	<k0vjq7$o7l$1@ultimate100.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 21 Aug 2012 09:19:03 +0000 (UTC)
Sven Geggus <lists@fuchsschwanzdomain.de> wrote:

> Sven Geggus <lists@fuchsschwanzdomain.de> wrote:
> 
> > So the question is what cases hangs in NFS4 based Linux systems in general
> > an in this particular case?
> 
> Digging this down a little bit further using wireshark I figured out that
> the server responds to the REMOVE .Xauthority call with an NFS4ERR_DELAY for
> whatever reason.
> 
> This is a currently a test-machine with one single user and next to zero
> load.
> 
> So I will probably need a hint on how to debug the server behaviour, as a
> NFS4ERR_DELAY response is definitely not expected in this case.
> 
> Sven
> 

It's often the case that this indicates a problem communicating over
the callback channel. For instance, the server is trying to recall a
delegation but the client isn't responding, so the server has to wait
until the recall attempt times out before proceeding.

-- 
Jeff Layton <jlayton@redhat.com>
