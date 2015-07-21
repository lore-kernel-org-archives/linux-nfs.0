Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38573 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754146AbbGUQDj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2015 12:03:39 -0400
Date: Tue, 21 Jul 2015 12:03:38 -0400
To: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Are there really no server-side mount/umount message for NFSv4?
Message-ID: <20150721160338.GD11050@fieldses.org>
References: <55AE4FC6.6050001@bio.ifi.lmu.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55AE4FC6.6050001@bio.ifi.lmu.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 21, 2015 at 03:57:26PM +0200, Frank Steiner wrote:
> we are missing the "authenticated u/mount request..." messages or 
> error messages like "refused mount request from /x (/): not exported"
> for NFSv4 servers. We were using the mount/umount messages e.g. to 
> detect when some reached a certain point of an installation etc.
> And the error messages on the server side often were more helpful
> than the ones on the client.
> 
> Is there really no way to get these easy-to-understand messages? 
> Debugging shows a lot but nothing that e.g. gives an understandable
> error reason.

There aren't any mount or umount calls in the NFSv4 protocol.

(For example, an NFSv4 server typically wouldn't have any way to tell
the difference between a client that has unmounted and one that just
isn't using the filesystem right now.)

If you could describe in more detail your use case, someone might be
able to suggest a different solution.  Or it might influence what sort
of information the nfs server exports to users in the future.

--b.
