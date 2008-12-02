From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH/RFC] svcgssd always sets an infinite expiry on authentication tokens etc.
Date: Tue, 2 Dec 2008 00:45:07 -0500
Message-ID: <4d569c330812012145y2353bc9asd7a0c62fef42ed3a@mail.gmail.com>
References: <18740.50457.981544.21225@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Steve Dickson" <SteveD@redhat.com>,
	"Kevin Coffman" <kwc@citi.umich.edu>
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:13336 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbYLBFpJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2008 00:45:09 -0500
Received: by wf-out-1314.google.com with SMTP id 27so3019843wfd.4
        for <linux-nfs@vger.kernel.org>; Mon, 01 Dec 2008 21:45:08 -0800 (PST)
In-Reply-To: <18740.50457.981544.21225-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,
This seems reasonable.

I have a patch somewhere that gets the actual Kerberos expiration that
could be used for the rsc timeout.  But I think this should be fine
for now.  (Perhaps at the cost of requiring clients to negotiate a new
context every hour?)

K.C.

On Tue, Dec 2, 2008 at 12:18 AM, Neil Brown <neilb@suse.de> wrote:
>
>
> Hi,
>  I have a report of an NFS server which runs out of kernel memory when
>  it gets heave rpcsec_gss traffic (auth_sys doesn't trigger the
>  problem so it must be gss related).
>
>  From looking at /proc/slab_allocators it seems that the main user of
>  memory is the rsc and rsi caches.
>  It appears entries are inserted into these caches with an expiry of
>  'forever' so they grow but never shrink.
>  We should fix this.
>
>  For the rsi (init) cache I assume the entry is only needed once so a
>  short expiry of (say) one minute should be plenty.
>  For the rsc (context) cache, the entry could be needed repeatedly
>  during the lifetime of a 'session'.  However eventually it will
>  become stale and should be allowed to expire.
>
>  I assume that if the kernel requests a particular entry a second
>  time, an hour later, it will get the same answer - is that correct?
>
>  In that case, setting the expiry to something largish seems
>  appropriate.
>
>  Hence the following patch (untested yet - but I will get it tested in
>  due course).
>
>  Does this seem reasonable?
>
> Thanks,
> NeilBrown
>
>
> diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
> index 794c2f4..088a007 100644
> --- a/utils/gssd/svcgssd_proc.c
> +++ b/utils/gssd/svcgssd_proc.c
> @@ -86,7 +86,9 @@ do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
>        }
>        qword_printhex(f, out_handle->value, out_handle->length);
>        /* XXX are types OK for the rest of this? */
> -       qword_printint(f, 0x7fffffff); /*XXX need a better timeout */
> +
> +       /* 'context' could be needed for a while. */
> +       qword_printint(f, time(0) + 60*60);
>        qword_printint(f, cred->cr_uid);
>        qword_printint(f, cred->cr_gid);
>        qword_printint(f, cred->cr_ngroups);
> @@ -130,7 +132,8 @@ send_response(FILE *f, gss_buffer_desc *in_handle, gss_buffer_desc *in_token,
>
>        qword_addhex(&bp, &blen, in_handle->value, in_handle->length);
>        qword_addhex(&bp, &blen, in_token->value, in_token->length);
> -       qword_addint(&bp, &blen, 0x7fffffff); /*XXX need a better timeout */
> +       /* INIT context info will only be needed for a short while */
> +       qword_addint(&bp, &blen, time(0) + 60);
>        qword_adduint(&bp, &blen, maj_stat);
>        qword_adduint(&bp, &blen, min_stat);
>        qword_addhex(&bp, &blen, out_handle->value, out_handle->length);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
