Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35908 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbcDKRsD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2016 13:48:03 -0400
Received: by mail-pa0-f68.google.com with SMTP id k3so10927436pav.3
        for <linux-nfs@vger.kernel.org>; Mon, 11 Apr 2016 10:48:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160411164154.GG4479@fieldses.org>
References: <CABQpAL4yG5P2M1SVX1sYRm_HQKMWS-06R7O+4wmd61WH1Fo4Sg@mail.gmail.com>
	<20160408211526.GC25179@fieldses.org>
	<CABQpAL5w=2nAUO0kOuR+pjo3q=9PCwO-QCCNAaTWAZU_r1nZEA@mail.gmail.com>
	<00f201d19408$87499250$95dcb6f0$@mindspring.com>
	<20160411164154.GG4479@fieldses.org>
Date: Mon, 11 Apr 2016 19:48:01 +0200
Message-ID: <CALXu0Ucx9vNDMRmAy+WOA-sUK8BWS5FU9UqQqRbr07Oy2=oq_g@mail.gmail.com>
Subject: Re: [Nfs-ganesha-devel] NFSv4 open close operations are slow compared
 to Linux kernel NFSv4
From: Cedric Blancher <cedric.blancher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Frank Filz <ffilzlnx@mindspring.com>, Tushar Shinde <mtk.tushar@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename "async" to "nodataconsistency"?

Ced

On 11 April 2016 at 18:41, J. Bruce Fields <bfields@fieldses.org> wrote:
> (Moving discussion to linux-nfs list, as it's no longer a Ganesha
> issue.)
>
> On Mon, Apr 11, 2016 at 08:40:50AM -0700, Frank Filz wrote:
>> Use of async on knfsd is not fair to use in performance evaluation. I have
>> long lobbied for renaming the async option to "I don't care about my data."
>
> Yes, renaming might be doable.  "I_dont_care_about_my_data" is a little
> cumbersome.  I'm not sure what's best.  Maybe "unsafe_commit"?  Though
> that might give the incorrect impression it's just about the commit
> operation.
>
> I'm not sure how to manage the transition.
>
>         - Even if they're using "async", they don't deserve to have
>           their server suddenly break on upgrade, so we need to continue
>           to respect "async" in existing /etc/exports files.
>         - Are there scripts that scan exports for "sync" or "async"
>           options anywhere, and how might they go wrong?  Maybe I'm
>           overthinking this.
>
> Maybe it'd be good enough to:
>
>         - keep kernel interfaces the same.
>         - in nfs-utils, use "unsafe_commit" in all output in place of
>           "async".  Accept "async" as a synonym, but possibly warn that
>           it's been renamed.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
