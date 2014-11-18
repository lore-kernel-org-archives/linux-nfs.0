Return-Path: keyrings-bounces@linux-nfs.org
From: David Howells <dhowells@redhat.com>
In-Reply-To: <8829.1416236894@warthog.procyon.org.uk>
References: <8829.1416236894@warthog.procyon.org.uk>
	<20141114153923.21180.66516.stgit@warthog.procyon.org.uk>
	<20141030174612.10093.61557.stgit@manet.1015granger.net>
To: chuck.lever@oracle.com, cth@carlh.net
MIME-Version: 1.0
Date: Tue, 18 Nov 2014 15:49:45 +0000
Message-ID: <21959.1416325785@warthog.procyon.org.uk>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org, keyrings@linux-nfs.org
Subject: Re: [Keyrings] [PATCH] KEYS: Simplify KEYRING_SEARCH_{NO,
	DO}_STATE_CHECK flags
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/keyrings>
List-Post: <mailto:keyrings@linux-nfs.org>
List-Help: <mailto:keyrings-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: keyrings-bounces@linux-nfs.org
Errors-To: keyrings-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> I'm not sure this patch actually solves your problem.
> 
> > request_key_and_link() depends on getting an -EAGAIN result code to know
> > when to perform an upcall to refresh an expired key.
> 
> request_key_and_link() should return EKEYEXPIRED if it meets an expired key
> until that key gets gc'd.
> 
> What we lack is that bit to upcall to refresh the expired key.
> /sbin/request-key can support it - the first column has 'create' for key
> creation and can hold other values for updating a key and KEYCTL_UPDATE can be
> allowed to unexpire a key.
> 
> Possibly I should be only returning EKEYEXPIRED if the key instantiation was
> rejected so and simply invalidate the key if it's in-memory expiration
> occurs.  Making this so will cause failures in the testsuite, but I think
> that's okay.
> 
> Another option is to allow keys to be specifically marked at
> immediate-gc-on-expire such that you never see them in the expired state
> unless you're holding a ref on one inside the kernel.

Having thought about it some more, I think the thing to do is to have
request_key() do as add_key() does and either replace or update a key that's
locally expired.

A key that was rejected (negatively instantiated) with EKEYEXPIRED as the
error to present should present that error instead with request_key() is
invoked.

Invalidated keys shouldn't be returned by the search algorithm.

Revoked keys should probably fail with EKEYREVOKED.  Invalidation rather than
revocation should be used to evict keys from memory.

Keyctl functions that access an expired key for other purposes, such as to
read the contents, should fail with EKEYEXPIRED still (apart from unlink and
invalidate which should always succeed given appropriate permissions).

I'm going to work on a patch on this basis.

David
_______________________________________________
Keyrings mailing list
Keyrings@linux-nfs.org
To change your subscription to this list, please see http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings
