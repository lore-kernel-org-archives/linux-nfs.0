Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:45423 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751148Ab1GLDvy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2011 23:51:54 -0400
Subject: Re: Umount and delegation release thread syncronization
From: Ian Kent <raven@themaw.net>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <1308555929.3306.43.camel@perseus.themaw.net>
References: <1308555929.3306.43.camel@perseus.themaw.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 12 Jul 2011 11:51:48 +0800
Message-ID: <1310442708.25348.10.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-06-20 at 15:45 +0800, Ian Kent wrote:
> Hi all,
> 
> I'm having difficulty working out how delegation release threads are
> synchronized with umount.
> 
> For an information about the problem please see
> https://bugzilla.kernel.org/show_bug.cgi?id=30882 and in particular
> comment #28.
> 
> Can someone please give me a description of the sequence of events at
> umount (aka. nfs4_kill_super() function calls). In particular how does
> nfs_free_server() know that if nfs_super_return_all_delegations() starts
> a thread that it is finished before freeing the server struct.

No response in almost a month. everyone must be really busy.

But does no-one know how this works?

Trond, could you have a look at the above bug and offer your input
please.

To be more specific, for the problem I'm asking about this is all we
have so far, http://obfusc.gavagai.nl/nfscrash.jpg.

As David Howells spotted the image shows that this isn't the first
backtrace from the crash so the answer may be "we can't tell" but how
about some help please.

> 
> Any information or observations about the opps in the above bug would
> also be appreciated.
> 
> Ian
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


