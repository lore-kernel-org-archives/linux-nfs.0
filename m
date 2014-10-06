Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:45608 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529AbaJFMzX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Oct 2014 08:55:23 -0400
Message-ID: <54329138.5020801@Netapp.com>
Date: Mon, 6 Oct 2014 08:55:20 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Carl Hetherington <cth@carlh.net>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] for intermittent erroneous uid/gid bug with NFS4/Kerberos
References: <alpine.DEB.2.02.1410032137370.27485@main.carlh.net>
In-Reply-To: <alpine.DEB.2.02.1410032137370.27485@main.carlh.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/03/14 16:39, Carl Hetherington wrote:
> Hi,
Hey Carl,

I'm having some trouble getting this patch to apply.  What version of the kernel did you develop it against?  You might also want to double check your formatting to make sure tabs and spaces aren't changed.

>
> I am investigating this bug:
> https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/1124250
> which is also:
> https://bugzilla.redhat.com/show_bug.cgi?id=876705
> and:
> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=758870
>
> After the keys which map NFS uid/gid to names expire there is sometimes a delay in them being recreated.  I believe this is because nfs_idmap_request_key calls request_key_with_auxdata which returns expired keys if they exist.  If this happens there is no-one to re-create the key.
>
> I think, instead, nfs_idmap_request_key should request a new key with a userspace upcall if its key for a particular name has expired.
>
> I have made the attached patch which fixes the problem in my tests.  It adds request_valid_key_with_auxdata() which does the same as request_key_with_auxdata() except that it ignores expired, revoked and invalidated keys.  It does this by passing KEYRING_SEARCH_DO_STATE_CHECK into the context for search_process_keyrings inside request_key_and_link. If all keys are expired, this function then asks userspace for an updated key.
Can you make this two separate patches?  One should be for the request_valid_key_with_auxdata() implementation, and the other with NFS changes.

Thanks,
Anna

>
> Can anyone offer any suggestions about whether this is along the right lines, or if not, what the right lines might be? :)
>
> Thanks & best regards,
> Carl
>
> Signed-off-by: Carl Hetherington <cth@carlh.net>
> ---
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index 567983d..744e40f 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -278,8 +278,8 @@ static struct key *nfs_idmap_request_key(const char *name, size_t namelen,
>       rkey = request_key(&key_type_id_resolver, desc, "");
>       if (IS_ERR(rkey)) {
>           mutex_lock(&idmap->idmap_mutex);
> -        rkey = request_key_with_auxdata(&key_type_id_resolver_legacy,
> -                        desc, "", 0, idmap);
> +        rkey = request_valid_key_with_auxdata(&key_type_id_resolver_legacy,
> +                              desc, "", 0, idmap);
>           mutex_unlock(&idmap->idmap_mutex);
>       }
>
> diff --git a/include/linux/key.h b/include/linux/key.h
> index 80d6774..6a4ef03 100644
> --- a/include/linux/key.h
> +++ b/include/linux/key.h
> @@ -252,6 +252,12 @@ extern struct key *request_key_with_auxdata(struct key_type *type,
>                           size_t callout_len,
>                           void *aux);
>
> +extern struct key *request_valid_key_with_auxdata(struct key_type *type,
> +                          const char *description,
> +                          const void *callout_info,
> +                          size_t callout_len,
> +                          void *aux);
> +
>   extern struct key *request_key_async(struct key_type *type,
>                        const char *description,
>                        const void *callout_info,
> diff --git a/security/keys/internal.h b/security/keys/internal.h
> index 80b2aac..5c9bc62 100644
> --- a/security/keys/internal.h
> +++ b/security/keys/internal.h
> @@ -150,7 +150,8 @@ extern struct key *request_key_and_link(struct key_type *type,
>                       size_t callout_len,
>                       void *aux,
>                       struct key *dest_keyring,
> -                    unsigned long flags);
> +                    unsigned long key_alloc_flags,
> +                    unsigned long keyring_search_flags);
>
>   extern int lookup_user_key_possessed(const struct key *key, const void *target);
>   extern key_ref_t lookup_user_key(key_serial_t id, unsigned long flags,
> diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
> index cee72ce..25a12bc 100644
> --- a/security/keys/keyctl.c
> +++ b/security/keys/keyctl.c
> @@ -212,7 +212,7 @@ SYSCALL_DEFINE4(request_key, const char __user *, _type,
>       /* do the search */
>       key = request_key_and_link(ktype, description, callout_info,
>                      callout_len, NULL, key_ref_to_ptr(dest_ref),
> -                   KEY_ALLOC_IN_QUOTA);
> +                   KEY_ALLOC_IN_QUOTA, 0);
>       if (IS_ERR(key)) {
>           ret = PTR_ERR(key);
>           goto error5;
> diff --git a/security/keys/request_key.c b/security/keys/request_key.c
> index 3814119..af8345c 100644
> --- a/security/keys/request_key.c
> +++ b/security/keys/request_key.c
> @@ -500,7 +500,11 @@ couldnt_alloc_key:
>    * @callout_len: The length of callout_info.
>    * @aux: Auxiliary data for the upcall.
>    * @dest_keyring: Where to cache the key.
> - * @flags: Flags to key_alloc().
> + * @key_alloc_flags: Flags to key_alloc().
> + * @keyring_search_flags: Flags to pass in the keyring search context
> + * (in addition to KEYRING_SEARCH_LOOKUP_DIRECT).  For example, passing
> + * KEYRING_SEARCH_DO_STATE_CHECK here will stop the function returning
> + * invalidated, revoked or expired keys.
>    *
>    * A key matching the specified criteria is searched for in the process's
>    * keyrings and returned with its usage count incremented if found. Otherwise,
> @@ -525,7 +529,8 @@ struct key *request_key_and_link(struct key_type *type,
>                    size_t callout_len,
>                    void *aux,
>                    struct key *dest_keyring,
> -                 unsigned long flags)
> +                 unsigned long key_alloc_flags,
> +                 unsigned long keyring_search_flags)
>   {
>       struct keyring_search_context ctx = {
>           .index_key.type        = type,
> @@ -533,7 +538,7 @@ struct key *request_key_and_link(struct key_type *type,
>           .cred            = current_cred(),
>           .match            = type->match,
>           .match_data        = description,
> -        .flags            = KEYRING_SEARCH_LOOKUP_DIRECT,
> +        .flags            = KEYRING_SEARCH_LOOKUP_DIRECT | keyring_search_flags
>       };
>       struct key *key;
>       key_ref_t key_ref;
> @@ -541,7 +546,7 @@ struct key *request_key_and_link(struct key_type *type,
>
>       kenter("%s,%s,%p,%zu,%p,%p,%lx",
>              ctx.index_key.type->name, ctx.index_key.description,
> -           callout_info, callout_len, aux, dest_keyring, flags);
> +           callout_info, callout_len, aux, dest_keyring, key_alloc_flags);
>
>       /* search all the process keyrings for a key */
>       key_ref = search_process_keyrings(&ctx);
> @@ -568,7 +573,7 @@ struct key *request_key_and_link(struct key_type *type,
>               goto error;
>
>           key = construct_key_and_link(&ctx, callout_info, callout_len,
> -                         aux, dest_keyring, flags);
> +                         aux, dest_keyring, key_alloc_flags);
>       }
>
>   error:
> @@ -629,7 +634,7 @@ struct key *request_key(struct key_type *type,
>       if (callout_info)
>           callout_len = strlen(callout_info);
>       key = request_key_and_link(type, description, callout_info, callout_len,
> -                   NULL, NULL, KEY_ALLOC_IN_QUOTA);
> +                   NULL, NULL, KEY_ALLOC_IN_QUOTA, 0);
>       if (!IS_ERR(key)) {
>           ret = wait_for_key_construction(key, false);
>           if (ret < 0) {
> @@ -665,7 +670,7 @@ struct key *request_key_with_auxdata(struct key_type *type,
>       int ret;
>
>       key = request_key_and_link(type, description, callout_info,
> callout_len,
> -                   aux, NULL, KEY_ALLOC_IN_QUOTA);
> +                   aux, NULL, KEY_ALLOC_IN_QUOTA, 0);
>       if (!IS_ERR(key)) {
>           ret = wait_for_key_construction(key, false);
>           if (ret < 0) {
> @@ -677,6 +682,42 @@ struct key *request_key_with_auxdata(struct key_type *type,
>   }
>   EXPORT_SYMBOL(request_key_with_auxdata);
>
> +/**
> + * request_valid_key_with_auxdata - Request a key with auxiliary data for the upcaller
> + * @type: The type of key we want.
> + * @description: The searchable description of the key.
> + * @callout_info: The data to pass to the instantiation upcall (or NULL).
> + * @callout_len: The length of callout_info.
> + * @aux: Auxiliary data for the upcall.
> + *
> + * As for request_key_with_auxdata() except that existing invalidated, revoked and expired
> + * keys are ignored during the search for the requested key.
> + *
> + * Furthermore, it then works as wait_for_key_construction() to wait for the
> + * completion of keys undergoing construction with a non-interruptible wait.
> + */
> +struct key *request_valid_key_with_auxdata(struct key_type *type,
> +                     const char *description,
> +                     const void *callout_info,
> +                     size_t callout_len,
> +                     void *aux)
> +{
> +    struct key *key;
> +    int ret;
> +
> +    key = request_key_and_link(type, description, callout_info, callout_len,
> +                   aux, NULL, KEY_ALLOC_IN_QUOTA, KEYRING_SEARCH_DO_STATE_CHECK);
> +    if (!IS_ERR(key)) {
> +        ret = wait_for_key_construction(key, false);
> +        if (ret < 0) {
> +            key_put(key);
> +            return ERR_PTR(ret);
> +        }
> +    }
> +    return key;
> +}
> +EXPORT_SYMBOL(request_valid_key_with_auxdata);
> +
>   /*
>    * request_key_async - Request a key (allow async construction)
>    * @type: Type of key.
> @@ -698,7 +739,7 @@ struct key *request_key_async(struct key_type *type,
>   {
>       return request_key_and_link(type, description, callout_info,
>                       callout_len, NULL, NULL,
> -                    KEY_ALLOC_IN_QUOTA);
> +                    KEY_ALLOC_IN_QUOTA, 0);
>   }
>   EXPORT_SYMBOL(request_key_async);
>
> @@ -723,6 +764,6 @@ struct key *request_key_async_with_auxdata(struct key_type *type,
>                          void *aux)
>   {
>       return request_key_and_link(type, description, callout_info,
> -                    callout_len, aux, NULL, KEY_ALLOC_IN_QUOTA);
> +                    callout_len, aux, NULL, KEY_ALLOC_IN_QUOTA, 0);
>   }
>   EXPORT_SYMBOL(request_key_async_with_auxdata);
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

