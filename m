Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964979Ab2CSOoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 10:44:11 -0400
Date: Mon, 19 Mar 2012 10:44:32 -0400
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: steved@redhat.com, jmorris@namei.org,
        linux-security-module@vger.kernel.org, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [Keyrings] [PATCH 7/9] KEYS: Permit in-place link replacement
 in keyring list
Message-ID: <20120319104432.56fe1e66@redhat.com>
In-Reply-To: <20120208110400.4050.11565.stgit@warthog.procyon.org.uk>
References: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
	<20120208110400.4050.11565.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 08 Feb 2012 11:04:00 +0000
David Howells <dhowells@redhat.com> wrote:

> @@ -154,11 +164,10 @@ static void keyring_destroy(struct key *keyring)
>  		write_unlock(&keyring_name_lock);
>  	}
>  
> -	klist = rcu_dereference_check(keyring->payload.subscriptions,
> -				      atomic_read(&keyring->usage) == 0);
> +	klist = rcu_access_pointer(keyring->payload.subscriptions);
>  	if (klist) {
>  		for (loop = klist->nkeys - 1; loop >= 0; loop--)
> -			key_put(klist->keys[loop]);
> +			key_put(rcu_access_pointer(klist->keys[loop]));
>  		kfree(klist);
>  	}
>  }

Why is it safe to use key_put(rcu_access_pointer(...)) ? Clearly that
pointer will end up being dereferenced, right?

-- 
Jeff Layton <jlayton@redhat.com>
