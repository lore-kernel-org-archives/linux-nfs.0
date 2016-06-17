Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60712 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341AbcFQPu4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jun 2016 11:50:56 -0400
Date: Fri, 17 Jun 2016 11:50:44 -0400
To: Martin Houry <martinhoury@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question : Session trunking fail-over
Message-ID: <20160617155044.GC29438@fieldses.org>
References: <CAEUt8VKFwMMkUCnbjy1m5Zht3yH83HMOo2T12oCVLwfzEP6D1Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAEUt8VKFwMMkUCnbjy1m5Zht3yH83HMOo2T12oCVLwfzEP6D1Q@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 17, 2016 at 09:08:45AM +0200, Martin Houry wrote:
> Hello, I have a question about Session trunking.
> In the RFC 5661 the  "2.10.13.1.2.Connection Loss" specify how to do
> if the LAST connection of the session is lost. There no specification
> when the lost connection is not the last connection of the session. Is
> there a fail-over mecanism for the session trunking connection loss?

I believe the RFC provides all the necessary protocol which a client
would need to implement such a failover mechanism.  The Linux client
doesn't currently attempt to do that.

--b.
