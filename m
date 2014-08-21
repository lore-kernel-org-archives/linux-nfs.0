Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65430 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313AbaHUPnf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Aug 2014 11:43:35 -0400
Message-ID: <53F612DC.60006@redhat.com>
Date: Thu, 21 Aug 2014 11:40:12 -0400
From: David Jeffery <djeffery@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: Always try and release an NFS file lock, even after
 receiving a SIGKILL
References: <1438879608.14503585.1407251825405.JavaMail.zimbra@redhat.com> <1408580933.4029.2.camel@leira.trondhjem.org>
In-Reply-To: <1408580933.4029.2.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/20/2014 08:28 PM, Trond Myklebust wrote:
> 
> What guarantees that this does not lead to silent corruption of the file
> if there are outstanding write requests?
> 

Do you have a particular scenario in mind you are concerned about?

Right before the code the patch modifies, nfs_sync_mapping() is called.
 Any writes started before the unlock operation began have already been
flushed, so we shouldn't have a corruption case of writes from before
the unlock began being sent after the unlock is complete.

Are you concerned about some other nfs4 writes being started while we
initially waited on the counter?  Such a write racing with the unlock
going ahead instead of erroring out could initially fail from a wrong
state ID, but should retry with the new state.  Is there something I've
overlooked?

David Jeffery
