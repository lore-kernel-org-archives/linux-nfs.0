Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:36660 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751935AbdBMLm6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2017 06:42:58 -0500
MIME-Version: 1.0
In-Reply-To: <20170213103815.GA5131@infradead.org>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
 <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
 <1486816302.4233.29.camel@poochiereds.net> <CAEXv5_gd7F-eaazzU1BWPzH4huhEcO1Y-FWov5UP9T+6R+fv-A@mail.gmail.com>
 <20170213103815.GA5131@infradead.org>
From: David Windsor <dwindsor@gmail.com>
Date: Mon, 13 Feb 2017 06:42:56 -0500
Message-ID: <CAEXv5_g=DS4wk0mgZuw-doVCqountb-CxZki1LOoQH-P7W1U4A@mail.gmail.com>
Subject: Re: [RFC][PATCH] nfsd: add +1 to reference counting scheme for struct nfsd4_session
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-hardening@lists.openwall.com,
        Bruce Fields <bfields@fieldses.org>, Kees Cook <keescook@chromium.org>,
        "Reshetova, Elena" <elena.reshetova@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 13, 2017 at 5:38 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Sat, Feb 11, 2017 at 09:01:15AM -0500, David Windsor wrote:
>> I'm not sure there's another way to accomplish what we need
>> (initializing struct nfsd4_session objects with refcount=1) without
>> also modifying the freeable reference state.  After migrating to the
>> refcount_t API, if we leave init_session() as is, the first call to
>> nfsd4_get_session_locked() will fail:
>
> Which is a pretty clear indicator that this code should simply not
> migrate to the recount_t API.  Why was it even considered if the
> conversion is obviously broken?

I'm not sure this is a sound argument for not converting to
refcount_t.  In other locations in which refcounting schemes are
"unnatural," i.e. freeing refcounted objects when their refcount is -1
(rather than 0), conversion to refcount_t is accomplished by
performing a logical +1 to the overall refcounting scheme.  We're
auditing all refcounting corner cases, such as these, to see if
similar solutions can be found.

Thanks,
David
