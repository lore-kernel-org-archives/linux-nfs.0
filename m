Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15811 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754853Ab1I1SXG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Sep 2011 14:23:06 -0400
Date: Wed, 28 Sep 2011 14:23:04 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd grace period open owners
Message-ID: <20110928182304.GJ19435@pad.fieldses.org>
References: <4E836218.6000805@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E836218.6000805@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 28, 2011 at 02:06:16PM -0400, Bryan Schumaker wrote:
> Hi Bruce,
> 
> I'm updating my fault injection patches to work with your recent stateid changes, and I had a question about something I'm seeing on the server.  When I reboot the server it will enter a grace period and reply to any OPEN requests from the client with NFSERR_GRACE.  I used Wireshark to see that NFSERR_GRACE is returned 12 times before the open succeeds, so 13 OPEN requests total.  When I send the command to forget all open owners I find that 13 open owners have been forgotten, but I only expecting to find 1.  Is this what you would expect the server to do?

Huh.  No, that doesn't sound right.  A failed open doesn't confirm the
openowner, and I don't think there's any reason to keep around an
unconfirmed openowner.

Out of curiosity, is the client using a different openowner for each
open?

--b.

> 
> I've pasted the code I use to count and delete open owners below.  The variable "num" has the value 0, so all open owners should be deleted.
> 
> - Bryan
> 
> static int nfsd_forget_n_openowners(u64 num)
> {
> 	int i, count = 0;
> 	struct nfs4_stateowner *sop, *next;
> 
> 	for (i = 0; i < OPEN_OWNER_HASH_SIZE; i++) {
> 		list_for_each_entry_safe(sop, next, &open_ownerstr_hashtbl[i], so_strhash) {
> 			release_openowner(openowner(sop));
> 			if (++count == num)
> 				return count;
> 		}
> 	}
> 	return count;
> }
> 
> void nfsd_forget_openowners(u64 num)
> {
> 	int count;
> 
> 	nfs4_lock_state();
> 	count = nfsd_forget_n_openowners(num);
> 	nfs4_unlock_state();
> 
> 	printk(KERN_INFO "%s %s Forgot %d open owners", __FILE__, __func__, count);
> }
