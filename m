Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39022 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964934AbbGVOdV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2015 10:33:21 -0400
Date: Wed, 22 Jul 2015 10:33:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Are there really no server-side mount/umount message for NFSv4?
Message-ID: <20150722143320.GE22718@fieldses.org>
References: <55AE4FC6.6050001@bio.ifi.lmu.de>
 <20150721160338.GD11050@fieldses.org>
 <55AF8907.1090807@bio.ifi.lmu.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55AF8907.1090807@bio.ifi.lmu.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 22, 2015 at 02:13:59PM +0200, Frank Steiner wrote:
> J. Bruce Fields wrote
> 
> > There aren't any mount or umount calls in the NFSv4 protocol.
> 
> Ok.
>  
> > (For example, an NFSv4 server typically wouldn't have any way to tell
> > the difference between a client that has unmounted and one that just
> > isn't using the filesystem right now.)
> > 
> > If you could describe in more detail your use case, someone might be
> > able to suggest a different solution.  Or it might influence what sort
> > of information the nfs server exports to users in the future.
> 
> The case where we watched the log file is very very specific and nothing
> that could not be solved otherwise. My main point was that we sometimes 
> ran into "could not mount blabla" on the client, and then the server 
> often gave a more detailed messages pointing us to the error. E.g. in
> NFSv4 we made a mistake by exporting our /nfsv4/ root, bind-mounted
> /nfsv4/x/ and exported onlt /nfsv4/ and /nfsv4/x/y to some client.
> Without any helpful error messages it took us some time to figure
> out that we had to export the whole bind-mount /nfsv4/x to the
> client or make another bindmount only for the /x/y/ subdir. 

Hm.  In this case I think there'd be evidence of the failure left in
/proc/net/rpc/nfsd.fh/content, though only after you turned on some rpc
debugging, which isn't something you'd want some program doing behind
your back.  There'd also be an upcall to rpc.mountd (at least on the
first failure), so simplest might be to add some optional logging there.
Might be worth looking into.  (I'm not volunteering for now.)

--b.
