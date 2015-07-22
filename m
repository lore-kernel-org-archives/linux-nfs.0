Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39024 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965323AbbGVOeG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2015 10:34:06 -0400
Date: Wed, 22 Jul 2015 10:34:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>, linux-nfs@vger.kernel.org
Subject: Re: Are there really no server-side mount/umount message for NFSv4?
Message-ID: <20150722143406.GF22718@fieldses.org>
References: <55AE4FC6.6050001@bio.ifi.lmu.de>
 <20150721160338.GD11050@fieldses.org>
 <1412102138.7789329.1437550284656.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1412102138.7789329.1437550284656.JavaMail.zimbra@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 22, 2015 at 09:31:24AM +0200, Mkrtchyan, Tigran wrote:
> With NFSv4.1 there are indirect hints to mount/umount: create and
> destroy session.

Yes, not sure that would have helped Frank in this case, but it'd be
useful some day to be able to e.g. query information about clients that
currently have established session (or other state).

--b.

> 
> Tigran.
> 
> ----- Original Message -----
> > From: "J. Bruce Fields" <bfields@fieldses.org>
> > To: "Frank Steiner" <fsteiner-mail1@bio.ifi.lmu.de>
> > Cc: linux-nfs@vger.kernel.org
> > Sent: Tuesday, July 21, 2015 6:03:38 PM
> > Subject: Re: Are there really no server-side mount/umount message for NFSv4?
> 
> > On Tue, Jul 21, 2015 at 03:57:26PM +0200, Frank Steiner wrote:
> >> we are missing the "authenticated u/mount request..." messages or
> >> error messages like "refused mount request from /x (/): not exported"
> >> for NFSv4 servers. We were using the mount/umount messages e.g. to
> >> detect when some reached a certain point of an installation etc.
> >> And the error messages on the server side often were more helpful
> >> than the ones on the client.
> >> 
> >> Is there really no way to get these easy-to-understand messages?
> >> Debugging shows a lot but nothing that e.g. gives an understandable
> >> error reason.
> > 
> > There aren't any mount or umount calls in the NFSv4 protocol.
> > 
> > (For example, an NFSv4 server typically wouldn't have any way to tell
> > the difference between a client that has unmounted and one that just
> > isn't using the filesystem right now.)
> > 
> > If you could describe in more detail your use case, someone might be
> > able to suggest a different solution.  Or it might influence what sort
> > of information the nfs server exports to users in the future.
> > 
> > --b.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
