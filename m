Return-Path: linux-nfs-owner@vger.kernel.org
Received: from auth-4.ukservers.net ([217.10.138.158]:36569 "EHLO
	auth-4.ukservers.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbaJGPUh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Oct 2014 11:20:37 -0400
Received: from main.carlh.net (unknown [37.139.5.111])
	(using TLSv1.2 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by auth-4.ukservers.net (Postfix smtp) with ESMTPS id B561A1CD9A63
	for <linux-nfs@vger.kernel.org>; Tue,  7 Oct 2014 16:20:35 +0100 (BST)
Received: from carl (helo=localhost)
	by main.carlh.net with local-esmtp (Exim 4.80)
	(envelope-from <cth@carlh.net>)
	id 1XbWYw-0004Nj-Tj
	for linux-nfs@vger.kernel.org; Tue, 07 Oct 2014 16:20:35 +0100
Date: Tue, 7 Oct 2014 16:20:30 +0100 (BST)
From: Carl Hetherington <cth@carlh.net>
To: linux-nfs@vger.kernel.org
In-Reply-To: <5432F6D2.10605@Netapp.com>
Message-ID: <alpine.DEB.2.02.1410071620040.27485@main.carlh.net>
References: <alpine.DEB.2.02.1410061533320.27485@main.carlh.net> <5432F6D2.10605@Netapp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Subject: Re: [PATCHv2 1/2] intermittent erroneous uid/gid bug with
 NFS4/Kerberos
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Anna,

Thank you.  I have just re-sent the patches, with git send-email this time
so hopefully the formatting is right!

Best regards,
Carl

On Mon, 6 Oct 2014, Anna Schumaker wrote:

> On 10/06/14 10:36, Carl Hetherington wrote:
> > KEYS: Add a new function request_valid_key_with_auxdata()
> I think this should be in the email subject line :).
>
> Since this patch isn't directly affecting NFS it should also be sent to David Howells (dhowells@redhat.com) and cc keyrings@linux-nfs.org.
>
> For whatever reason, both patches have an extra space before each "context" line.  They apply after removing the extra whitespace, but you might want to double check your mailer settings to make sure it's not messing something up.
>
> Anna
> > which does as request_key_with_auxdata() except that invalidated, revoked and
> > expired keys are ignored during the search for the requested key.
> >
> > Signed-off-by: Carl Hetherington <cth@carlh.net>
> > ---
> >  include/linux/key.h         |  6 +++++
> >  security/keys/internal.h    |  3 ++-
> >  security/keys/keyctl.c      |  2 +-
> >  security/keys/request_key.c | 59 ++++++++++++++++++++++++++++++++++++++-------
> >  4 files changed, 59 insertions(+), 11 deletions(-)
> >
> > diff --git a/include/linux/key.h b/include/linux/key.h
> > index 80d6774..6a4ef03 100644
> > --- a/include/linux/key.h
> > +++ b/include/linux/key.h
> > @@ -252,6 +252,12 @@ extern struct key *request_key_with_auxdata(struct key_type *type,
> >                          size_t callout_len,
> >                          void *aux);
> >
> > +extern struct key *request_valid_key_with_auxdata(struct key_type *type,
> > +                          const char *description,
> > +                          const void *callout_info,
> > +                          size_t callout_len,
> > +                          void *aux);
> > +
> >  extern struct key *request_key_async(struct key_type *type,
> >                       const char *description,
> >                       const void *callout_info,
> > diff --git a/security/keys/internal.h b/security/keys/internal.h
> > index 80b2aac..5c9bc62 100644
> > --- a/security/keys/internal.h
> > +++ b/security/keys/internal.h
> > @@ -150,7 +150,8 @@ extern struct key *request_key_and_link(struct key_type *type,
> >                      size_t callout_len,
> >                      void *aux,
> >                      struct key *dest_keyring,
> > -                    unsigned long flags);
> > +                    unsigned long key_alloc_flags,
> > +                    unsigned long keyring_search_flags);
> >
> >  extern int lookup_user_key_possessed(const struct key *key, const void *target);
> >  extern key_ref_t lookup_user_key(key_serial_t id, unsigned long flags,
> > diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
> > index cee72ce..25a12bc 100644
> > --- a/security/keys/keyctl.c
> > +++ b/security/keys/keyctl.c
> > @@ -212,7 +212,7 @@ SYSCALL_DEFINE4(request_key, const char __user *, _type,
> >      /* do the search */
> >      key = request_key_and_link(ktype, description, callout_info,
> >                     callout_len, NULL, key_ref_to_ptr(dest_ref),
> > -                   KEY_ALLOC_IN_QUOTA);
> > +                   KEY_ALLOC_IN_QUOTA, 0);
> >      if (IS_ERR(key)) {
> >          ret = PTR_ERR(key);
> >          goto error5;
> > diff --git a/security/keys/request_key.c b/security/keys/request_key.c
> > index 3814119..9f78aed 100644
> > --- a/security/keys/request_key.c
> > +++ b/security/keys/request_key.c
> > @@ -500,7 +500,11 @@ couldnt_alloc_key:
> >   * @callout_len: The length of callout_info.
> >   * @aux: Auxiliary data for the upcall.
> >   * @dest_keyring: Where to cache the key.
> > - * @flags: Flags to key_alloc().
> > + * @key_alloc_flags: Flags to key_alloc().
> > + * @keyring_search_flags: Flags to pass in the keyring search context
> > + * (in addition to KEYRING_SEARCH_LOOKUP_DIRECT).  For example, passing
> > + * KEYRING_SEARCH_DO_STATE_CHECK here will stop the function returning
> > + * invalidated, revoked or expired keys.
> >   *
> >   * A key matching the specified criteria is searched for in the process's
> >   * keyrings and returned with its usage count incremented if found.  Otherwise,
> > @@ -525,7 +529,8 @@ struct key *request_key_and_link(struct key_type *type,
> >                   size_t callout_len,
> >                   void *aux,
> >                   struct key *dest_keyring,
> > -                 unsigned long flags)
> > +                 unsigned long key_alloc_flags,
> > +                 unsigned long keyring_search_flags)
> >  {
> >      struct keyring_search_context ctx = {
> >          .index_key.type        = type,
> > @@ -533,7 +538,7 @@ struct key *request_key_and_link(struct key_type *type,
> >          .cred            = current_cred(),
> >          .match            = type->match,
> >          .match_data        = description,
> > -        .flags            = KEYRING_SEARCH_LOOKUP_DIRECT,
> > +        .flags            = KEYRING_SEARCH_LOOKUP_DIRECT | keyring_search_flags,
> >      };
> >      struct key *key;
> >      key_ref_t key_ref;
> > @@ -541,7 +546,7 @@ struct key *request_key_and_link(struct key_type *type,
> >
> >      kenter("%s,%s,%p,%zu,%p,%p,%lx",
> >             ctx.index_key.type->name, ctx.index_key.description,
> > -           callout_info, callout_len, aux, dest_keyring, flags);
> > +           callout_info, callout_len, aux, dest_keyring, key_alloc_flags);
> >
> >      /* search all the process keyrings for a key */
> >      key_ref = search_process_keyrings(&ctx);
> > @@ -568,7 +573,7 @@ struct key *request_key_and_link(struct key_type *type,
> >              goto error;
> >
> >          key = construct_key_and_link(&ctx, callout_info, callout_len,
> > -                         aux, dest_keyring, flags);
> > +                         aux, dest_keyring, key_alloc_flags);
> >      }
> >
> >  error:
> > @@ -629,7 +634,7 @@ struct key *request_key(struct key_type *type,
> >      if (callout_info)
> >          callout_len = strlen(callout_info);
> >      key = request_key_and_link(type, description, callout_info, callout_len,
> > -                   NULL, NULL, KEY_ALLOC_IN_QUOTA);
> > +                   NULL, NULL, KEY_ALLOC_IN_QUOTA, 0);
> >      if (!IS_ERR(key)) {
> >          ret = wait_for_key_construction(key, false);
> >          if (ret < 0) {
> > @@ -665,7 +670,7 @@ struct key *request_key_with_auxdata(struct key_type *type,
> >      int ret;
> >
> >      key = request_key_and_link(type, description, callout_info, callout_len,
> > -                   aux, NULL, KEY_ALLOC_IN_QUOTA);
> > +                   aux, NULL, KEY_ALLOC_IN_QUOTA, 0);
> >      if (!IS_ERR(key)) {
> >          ret = wait_for_key_construction(key, false);
> >          if (ret < 0) {
> > @@ -677,6 +682,42 @@ struct key *request_key_with_auxdata(struct key_type *type,
> >  }
> >  EXPORT_SYMBOL(request_key_with_auxdata);
> >
> > +/**
> > + * request_valid_key_with_auxdata - Request a key with auxiliary data for the upcaller
> > + * @type: The type of key we want.
> > + * @description: The searchable description of the key.
> > + * @callout_info: The data to pass to the instantiation upcall (or NULL).
> > + * @callout_len: The length of callout_info.
> > + * @aux: Auxiliary data for the upcall.
> > + *
> > + * As for request_key_with_auxdata() except that existing invalidated, revoked and expired
> > + * keys are ignored during the search for the requested key.
> > + *
> > + * Furthermore, it then works as wait_for_key_construction() to wait for the
> > + * completion of keys undergoing construction with a non-interruptible wait.
> > + */
> > +struct key *request_valid_key_with_auxdata(struct key_type *type,
> > +                     const char *description,
> > +                     const void *callout_info,
> > +                     size_t callout_len,
> > +                     void *aux)
> > +{
> > +    struct key *key;
> > +    int ret;
> > +
> > +    key = request_key_and_link(type, description, callout_info, callout_len,
> > +                   aux, NULL, KEY_ALLOC_IN_QUOTA, KEYRING_SEARCH_DO_STATE_CHECK);
> > +    if (!IS_ERR(key)) {
> > +        ret = wait_for_key_construction(key, false);
> > +        if (ret < 0) {
> > +            key_put(key);
> > +            return ERR_PTR(ret);
> > +        }
> > +    }
> > +    return key;
> > +}
> > +EXPORT_SYMBOL(request_valid_key_with_auxdata);
> > +
> >  /*
> >   * request_key_async - Request a key (allow async construction)
> >   * @type: Type of key.
> > @@ -698,7 +739,7 @@ struct key *request_key_async(struct key_type *type,
> >  {
> >      return request_key_and_link(type, description, callout_info,
> >                      callout_len, NULL, NULL,
> > -                    KEY_ALLOC_IN_QUOTA);
> > +                    KEY_ALLOC_IN_QUOTA, 0);
> >  }
> >  EXPORT_SYMBOL(request_key_async);
> >
> > @@ -723,6 +764,6 @@ struct key *request_key_async_with_auxdata(struct key_type *type,
> >                         void *aux)
> >  {
> >      return request_key_and_link(type, description, callout_info,
> > -                    callout_len, aux, NULL, KEY_ALLOC_IN_QUOTA);
> > +                    callout_len, aux, NULL, KEY_ALLOC_IN_QUOTA, 0);
> >  }
> >  EXPORT_SYMBOL(request_key_async_with_auxdata);
>
>
>
