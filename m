Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933279AbaKMP34 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Nov 2014 10:29:56 -0500
Date: Thu, 13 Nov 2014 10:29:49 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
cc: Neil Brown <neilb@suse.de>, David Howells <dhowells@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] KEYS: Ensure expired keys are renewed
In-Reply-To: <37307506-F6EC-4EF8-A8F4-50795D66AD83@oracle.com>
Message-ID: <alpine.LRH.2.11.1411131026510.20279@sh-el6.eng.rdu2.redhat.com>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net> <20141113111558.7775022e@notabene.brown> <37307506-F6EC-4EF8-A8F4-50795D66AD83@oracle.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="168445344-536771864-1415892590=:20279"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--168445344-536771864-1415892590=:20279
Content-Type: TEXT/PLAIN; charset=windows-1252
Content-Transfer-Encoding: 8BIT


On Thu, 13 Nov 2014, Chuck Lever wrote:

>
> On Nov 12, 2014, at 6:15 PM, NeilBrown <neilb@suse.de> wrote:
>
> > On Thu, 30 Oct 2014 13:46:47 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
> >
> >> After about 10 minutes, my NFSv4 functional tests fail because the
> >> ownership of the test files goes to "-2". Looking at /proc/keys
> >> shows that the id_resolv keys that map to my test user ID have
> >> expired. The ownership problem persists until the expired keys are
> >> purged from the keyring, and fresh keys are obtained.
> >>
> >> I bisected the problem to 3.13 commit b2a4df200d57 ("KEYS: Expand
> >> the capacity of a keyring"). This commit inadvertantly changes the
> >> API contract of the internal function keyring_search_aux().
> >>
> >> The root cause appears to be that b2a4df200d57 made "no state check"
> >> the default behavior. "No state check" means the keyring search
> >> iterator function skips checking the key's expiry timeout, and
> >> returns expired keys.  request_key_and_link() depends on getting
> >> an -EAGAIN result code to know when to perform an upcall to refresh
> >> an expired key.
> >>
> >> Restore the previous default behavior of keyring_search_aux() and
> >> the meaning of the KEYRING_SEARCH_{DO,NO}_STATE_CHECK flags.
> >>
> >> Fixes: b2a4df200d57 ("KEYS: Expand the capacity of a keyring")
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> Resend with correct linux-nfs address.
> >>
> >> security/keys/keyring.c |   11 +++++++----
> >> 1 file changed, 7 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/security/keys/keyring.c b/security/keys/keyring.c
> >> index 8314a7d..1294582 100644
> >> --- a/security/keys/keyring.c
> >> +++ b/security/keys/keyring.c
> >> @@ -519,9 +519,14 @@ static int keyring_search_iterator(const void *object, void *iterator_data)
> >> 	struct keyring_search_context *ctx = iterator_data;
> >> 	const struct key *key = keyring_ptr_to_key(object);
> >> 	unsigned long kflags = key->flags;
> >> +	bool state_check_needed;
> >>
> >> 	kenter("{%d}", key->serial);
> >>
> >> +	state_check_needed = !(ctx->flags & KEYRING_SEARCH_NO_STATE_CHECK);
> >> +	if (ctx->flags & KEYRING_SEARCH_DO_STATE_CHECK)
> >> +		state_check_needed = true;
> >> +
> >> 	/* ignore keys not of this type */
> >> 	if (key->type != ctx->index_key.type) {
> >> 		kleave(" = 0 [!type]");
> >> @@ -529,7 +534,7 @@ static int keyring_search_iterator(const void *object, void *iterator_data)
> >> 	}
> >>
> >> 	/* skip invalidated, revoked and expired keys */
> >> -	if (ctx->flags & KEYRING_SEARCH_DO_STATE_CHECK) {
> >> +	if (state_check_needed) {
> >> 		if (kflags & ((1 << KEY_FLAG_INVALIDATED) |
> >> 			      (1 << KEY_FLAG_REVOKED))) {
> >> 			ctx->result = ERR_PTR(-EKEYREVOKED);
> >> @@ -559,7 +564,7 @@ static int keyring_search_iterator(const void *object, void *iterator_data)
> >> 		goto skipped;
> >> 	}
> >>
> >> -	if (ctx->flags & KEYRING_SEARCH_DO_STATE_CHECK) {
> >> +	if (state_check_needed) {
> >> 		/* we set a different error code if we pass a negative key */
> >> 		if (kflags & (1 << KEY_FLAG_NEGATIVE)) {
> >> 			smp_rmb();
> >> @@ -642,8 +647,6 @@ static bool search_nested_keyrings(struct key *keyring,
> >> 	}
> >>
> >> 	ctx->skipped_ret = 0;
> >> -	if (ctx->flags & KEYRING_SEARCH_NO_STATE_CHECK)
> >> -		ctx->flags &= ~KEYRING_SEARCH_DO_STATE_CHECK;
> >>
> >> 	/* Start processing a new keyring */
> >> descend_to_keyring:
> >>
> >
> > Reviewed-by: NeilBrown <neilb@suse.de>
>
> Thanks!
>
> > security/keys/internal.h says:
> >
> > #define KEYRING_SEARCH_NO_STATE_CHECK   0x0001  /* Skip state checks */
> > #define KEYRING_SEARCH_DO_STATE_CHECK   0x0002  /* Override NO_STATE_CHECK */
> >
> >
> > Your match makes it obvious that DO overrides NO.  The current code
> > doesn't get that right.
> >
> > Is this on its way upstream yet (not in -next that I could see).
>
> I’ve gotten no response on this patch. Maybe I sent it to the
> wrong mailing list?

There's http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings for this,
but I think it's fairly broken.  My messages sent there have been
disappearing.  :/

Bruce, Trond - any idea what's wrong with the keyrings list?  I'd be
happy to attempt the repairs myself if time is the problem..

Ben
--168445344-536771864-1415892590=:20279--
