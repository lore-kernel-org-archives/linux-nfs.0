Return-Path: keyrings-bounces@linux-nfs.org
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <8829.1416236894@warthog.procyon.org.uk>
Date: Mon, 17 Nov 2014 10:48:53 -0500
Message-Id: <19E2E17C-D013-4B9F-B4A9-A1C96803A6CB@oracle.com>
References: <20141114153923.21180.66516.stgit@warthog.procyon.org.uk>
	<20141030174612.10093.61557.stgit@manet.1015granger.net>
	<8829.1416236894@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: Neil Brown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        keyrings@linux-nfs.org
Subject: Re: [Keyrings] [PATCH] KEYS: Simplify KEYRING_SEARCH_{NO,
	DO}_STATE_CHECK flags
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/keyrings>
List-Post: <mailto:keyrings@linux-nfs.org>
List-Help: <mailto:keyrings-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="windows-1252"
Sender: keyrings-bounces@linux-nfs.org
Errors-To: keyrings-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David-

On Nov 17, 2014, at 10:08 AM, David Howells <dhowells@redhat.com> wrote:

> I'm not sure this patch actually solves your problem.
> =

>> request_key_and_link() depends on getting an -EAGAIN result code to know
>> when to perform an upcall to refresh an expired key.
> =

> request_key_and_link() should return EKEYEXPIRED if it meets an expired k=
ey
> until that key gets gc=92d.

That=92s what the documenting comment says, but...

nfs_idmap_request_key() considers any error return from
request_key() to be a reason to fall back to using the
legacy (non-keyring-based) ID mapper.

nfs_idmap_get_key() considers any error return from
key_validate() to be a permanent error.

IOW the NFS idmapper logic depends on getting a valid key
back from request_key() ie, one that has not expired,
or one that was just refreshed. Getting back an expired
key or getting -EKEYEXPIRED is unexpected.

Thus it appears to be an API contract change. At least,
the documenting comment in front of request_key_and_link()
does not seem to match the current design of the NFS
idmapper code.

> What we lack is that bit to upcall to refresh the expired key.

Currently request_key_and_link() expects -EAGAIN from
search_process_keyrings() to know when it should upcall.
But, maybe something else is needed there instead.

> /sbin/request-key can support it - the first column has 'create' for key
> creation and can hold other values for updating a key and KEYCTL_UPDATE c=
an be
> allowed to unexpire a key.
> =

> Possibly I should be only returning EKEYEXPIRED if the key instantiation =
was
> rejected so and simply invalidate the key if it's in-memory expiration
> occurs.  Making this so will cause failures in the testsuite, but I think
> that's okay.
> =

> Another option is to allow keys to be specifically marked at
> immediate-gc-on-expire such that you never see them in the expired state
> unless you're holding a ref on one inside the kernel.

As long as request_key_and_link() can=92t return an
expired key.

Another option is to alter the NFS idmapper logic
to match the current keyring API contract. I didn=92t
choose that option before because it seemed like it
wasn=92t the intention to change that contract in
3.13.

I'll hold off on testing the patches you sent over
the weekend.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



_______________________________________________
Keyrings mailing list
Keyrings@linux-nfs.org
To change your subscription to this list, please see http://linux-nfs.org/c=
gi-bin/mailman/listinfo/keyrings
