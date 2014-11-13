Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:44493 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933040AbaKMPJI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Nov 2014 10:09:08 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] KEYS: Ensure expired keys are renewed
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20141113111558.7775022e@notabene.brown>
Date: Thu, 13 Nov 2014 09:09:02 -0600
Cc: David Howells <dhowells@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <37307506-F6EC-4EF8-A8F4-50795D66AD83@oracle.com>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net> <20141113111558.7775022e@notabene.brown>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2014, at 6:15 PM, NeilBrown <neilb@suse.de> wrote:

> On Thu, 30 Oct 2014 13:46:47 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> After about 10 minutes, my NFSv4 functional tests fail because the
>> ownership of the test files goes to "-2". Looking at /proc/keys
>> shows that the id_resolv keys that map to my test user ID have
>> expired. The ownership problem persists until the expired keys are
>> purged from the keyring, and fresh keys are obtained.
>> 
>> I bisected the problem to 3.13 commit b2a4df200d57 ("KEYS: Expand
>> the capacity of a keyring"). This commit inadvertantly changes the
>> API contract of the internal function keyring_search_aux().
>> 
>> The root cause appears to be that b2a4df200d57 made "no state check"
>> the default behavior. "No state check" means the keyring search
>> iterator function skips checking the key's expiry timeout, and
>> returns expired keys.  request_key_and_link() depends on getting
>> an -EAGAIN result code to know when to perform an upcall to refresh
>> an expired key.
>> 
>> Restore the previous default behavior of keyring_search_aux() and
>> the meaning of the KEYRING_SEARCH_{DO,NO}_STATE_CHECK flags.
>> 
>> Fixes: b2a4df200d57 ("KEYS: Expand the capacity of a keyring")
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> Resend with correct linux-nfs address.
>> 
>> security/keys/keyring.c |   11 +++++++----
>> 1 file changed, 7 insertions(+), 4 deletions(-)
>> 
>> diff --git a/security/keys/keyring.c b/security/keys/keyring.c
>> index 8314a7d..1294582 100644
>> --- a/security/keys/keyring.c
>> +++ b/security/keys/keyring.c
>> @@ -519,9 +519,14 @@ static int keyring_search_iterator(const void *object, void *iterator_data)
>> 	struct keyring_search_context *ctx = iterator_data;
>> 	const struct key *key = keyring_ptr_to_key(object);
>> 	unsigned long kflags = key->flags;
>> +	bool state_check_needed;
>> 
>> 	kenter("{%d}", key->serial);
>> 
>> +	state_check_needed = !(ctx->flags & KEYRING_SEARCH_NO_STATE_CHECK);
>> +	if (ctx->flags & KEYRING_SEARCH_DO_STATE_CHECK)
>> +		state_check_needed = true;
>> +
>> 	/* ignore keys not of this type */
>> 	if (key->type != ctx->index_key.type) {
>> 		kleave(" = 0 [!type]");
>> @@ -529,7 +534,7 @@ static int keyring_search_iterator(const void *object, void *iterator_data)
>> 	}
>> 
>> 	/* skip invalidated, revoked and expired keys */
>> -	if (ctx->flags & KEYRING_SEARCH_DO_STATE_CHECK) {
>> +	if (state_check_needed) {
>> 		if (kflags & ((1 << KEY_FLAG_INVALIDATED) |
>> 			      (1 << KEY_FLAG_REVOKED))) {
>> 			ctx->result = ERR_PTR(-EKEYREVOKED);
>> @@ -559,7 +564,7 @@ static int keyring_search_iterator(const void *object, void *iterator_data)
>> 		goto skipped;
>> 	}
>> 
>> -	if (ctx->flags & KEYRING_SEARCH_DO_STATE_CHECK) {
>> +	if (state_check_needed) {
>> 		/* we set a different error code if we pass a negative key */
>> 		if (kflags & (1 << KEY_FLAG_NEGATIVE)) {
>> 			smp_rmb();
>> @@ -642,8 +647,6 @@ static bool search_nested_keyrings(struct key *keyring,
>> 	}
>> 
>> 	ctx->skipped_ret = 0;
>> -	if (ctx->flags & KEYRING_SEARCH_NO_STATE_CHECK)
>> -		ctx->flags &= ~KEYRING_SEARCH_DO_STATE_CHECK;
>> 
>> 	/* Start processing a new keyring */
>> descend_to_keyring:
>> 
> 
> Reviewed-by: NeilBrown <neilb@suse.de>

Thanks!

> security/keys/internal.h says:
> 
> #define KEYRING_SEARCH_NO_STATE_CHECK   0x0001  /* Skip state checks */
> #define KEYRING_SEARCH_DO_STATE_CHECK   0x0002  /* Override NO_STATE_CHECK */
> 
> 
> Your match makes it obvious that DO overrides NO.  The current code
> doesn't get that right.
> 
> Is this on its way upstream yet (not in -next that I could see).

I’ve gotten no response on this patch. Maybe I sent it to the
wrong mailing list?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



