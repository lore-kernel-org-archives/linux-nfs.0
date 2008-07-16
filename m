From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] umount: fix problems when portmap doesn't listen on UDP.
Date: Wed, 16 Jul 2008 14:49:47 -0400
Message-ID: <487E42CB.4040509@RedHat.com>
References: <18556.40326.764642.102066@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49768 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297AbYGPSuV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2008 14:50:21 -0400
In-Reply-To: <18556.40326.764642.102066-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Neil Brown wrote:
> Another patch that can be pulled from 
>      git://neil.brown.name/nfs-utils for-steved
> 
> This and the next deal with problems with the new 'string based
> option' code when portmap can only be contacted via TCP.
> 
> Some people seem to turn of string based options to avoid this
> problem:
>   https://bugs.launchpad.net/ubuntu/+bug/213444/comments/23
> 
> This can partly be avoided using mountproto=tcp, but that
>   a/ shouldn't be needed (isn't with the old code)
>   b/ doesn't help the unmount case.
> 
> This first patch make umount work better if mountproto=tcp was given
> to mount.
> The next patch gives mountproto=tcp to mount if it is needed.
Committed

steved.
