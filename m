From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] umount: fix problems when portmap doesn't listen on UDP.
Date: Thu, 17 Jul 2008 12:44:42 +1000
Message-ID: <18558.45595.59801.775326@notabene.brown>
References: <18556.40326.764642.102066@notabene.brown>
	<487E42CB.4040509@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:47807 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470AbYGQCoq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2008 22:44:46 -0400
In-Reply-To: message from Steve Dickson on Wednesday July 16
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday July 16, SteveD@redhat.com wrote:
> 
> 
> Neil Brown wrote:
> > Another patch that can be pulled from 
> >      git://neil.brown.name/nfs-utils for-steved
> > 
> > This and the next deal with problems with the new 'string based
> > option' code when portmap can only be contacted via TCP.
> > 
> > Some people seem to turn of string based options to avoid this
> > problem:
> >   https://bugs.launchpad.net/ubuntu/+bug/213444/comments/23
> > 
> > This can partly be avoided using mountproto=tcp, but that
> >   a/ shouldn't be needed (isn't with the old code)
> >   b/ doesn't help the unmount case.
> > 
> > This first patch make umount work better if mountproto=tcp was given
> > to mount.
> > The next patch gives mountproto=tcp to mount if it is needed.
> Committed
> 
> steved.

Thanks!
Do you have plans for a 1.1.3?
15th of September would be 6 months since 1.1.2 :-)

NeilBrown
