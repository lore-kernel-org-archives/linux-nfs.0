Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21004 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754520Ab1I1SGe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Sep 2011 14:06:34 -0400
Message-ID: <4E836218.6000805@netapp.com>
Date: Wed, 28 Sep 2011 14:06:16 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: nfsd grace period open owners
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce,

I'm updating my fault injection patches to work with your recent stateid changes, and I had a question about something I'm seeing on the server.  When I reboot the server it will enter a grace period and reply to any OPEN requests from the client with NFSERR_GRACE.  I used Wireshark to see that NFSERR_GRACE is returned 12 times before the open succeeds, so 13 OPEN requests total.  When I send the command to forget all open owners I find that 13 open owners have been forgotten, but I only expecting to find 1.  Is this what you would expect the server to do?

I've pasted the code I use to count and delete open owners below.  The variable "num" has the value 0, so all open owners should be deleted.

- Bryan

static int nfsd_forget_n_openowners(u64 num)
{
	int i, count = 0;
	struct nfs4_stateowner *sop, *next;

	for (i = 0; i < OPEN_OWNER_HASH_SIZE; i++) {
		list_for_each_entry_safe(sop, next, &open_ownerstr_hashtbl[i], so_strhash) {
			release_openowner(openowner(sop));
			if (++count == num)
				return count;
		}
	}
	return count;
}

void nfsd_forget_openowners(u64 num)
{
	int count;

	nfs4_lock_state();
	count = nfsd_forget_n_openowners(num);
	nfs4_unlock_state();

	printk(KERN_INFO "%s %s Forgot %d open owners", __FILE__, __func__, count);
}
