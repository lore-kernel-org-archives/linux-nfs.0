Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:33126 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753956AbdBNNs1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Feb 2017 08:48:27 -0500
MIME-Version: 1.0
In-Reply-To: <20170213121238.GA4753@infradead.org>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
 <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
 <1486816302.4233.29.camel@poochiereds.net> <CAEXv5_gd7F-eaazzU1BWPzH4huhEcO1Y-FWov5UP9T+6R+fv-A@mail.gmail.com>
 <20170213103815.GA5131@infradead.org> <CAEXv5_g=DS4wk0mgZuw-doVCqountb-CxZki1LOoQH-P7W1U4A@mail.gmail.com>
 <20170213121238.GA4753@infradead.org>
From: David Windsor <dwindsor@gmail.com>
Date: Tue, 14 Feb 2017 08:48:26 -0500
Message-ID: <CAEXv5_ifq6gO1eBueYGCL21QBAsCQNZROxGCuEYWSNmXz7OTeQ@mail.gmail.com>
Subject: Re: [RFC][PATCH] nfsd: add +1 to reference counting scheme for struct nfsd4_session
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-hardening@lists.openwall.com,
        Bruce Fields <bfields@fieldses.org>, Kees Cook <keescook@chromium.org>,
        "Reshetova, Elena" <elena.reshetova@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 13, 2017 at 7:12 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Feb 13, 2017 at 06:42:56AM -0500, David Windsor wrote:
>> I'm not sure this is a sound argument for not converting to
>> refcount_t.
>
> It's an argument again the way how this patch was sent.  Please take care
> of all the trivial conversions first, and then do anything non-trivial
> on a case by case basis.

This is actually what we're currently doing.

The vast majority of atomic_t to refcount_t conversions are trivial,
as they most always follow the pattern:

1.  Initialize the atomic_t refcounter to 1.
2.  Perform shared object get/put operations.
3.  Free the shared object when its refcount becomes 0.

We've identified a handful of instances in which steps 1 and 3 are
different from above (i.e. initializing refcounts to 0, freeing
objects when refcount is non-zero, etc.).  The above patch addresses
one of these instances in NFS.

Thanks,
David
