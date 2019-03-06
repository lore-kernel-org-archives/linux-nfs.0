Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E953DC43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 07:09:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B52BF2064A
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 07:09:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IQPB3f0S"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729037AbfCFHJd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 02:09:33 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:38748 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726145AbfCFHJd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2019 02:09:33 -0500
Received: by mail-yw1-f68.google.com with SMTP id o184so9129205ywo.5;
        Tue, 05 Mar 2019 23:09:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3zBuV17I5sWNzu5F2rgnNcAnFnr0PboJ9pM364Vyw7o=;
        b=IQPB3f0S7FAODtycXQAIxOCJeu+2i+sBnw9pSl1aUZerMJsPsFiCrrlqME4oiwT4P7
         3Pn23+ZXInvFuEjGQxT5mDR5OgstjzykhEo90YrdRqZy69Hmz+JZTowN9GPX+pF2+xJF
         u+ewHkwruPwl7Z/gCeMYpxru2D6b2hlcvds5tlCSe7eKGq/ncYsImTbXkQengDViM+/r
         GEfcUGzJRlTMXxqh/XYvr23jTLvQDb+4goG6jySPKZlwqW1ZeuQfqbYWpSp0/gqWjCK7
         pVqVK+KiLHs0vHUKk59ESxjXwzKmj6sRKBfC3JtJozUvRO9xPYUjCaZ+VQIu+KnsbeZN
         c6kQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=3zBuV17I5sWNzu5F2rgnNcAnFnr0PboJ9pM364Vyw7o=;
        b=LC9JT1cPezVccG/l7T6YoFy0k+VKD8s6c5LV8iLKxhp3CUz9rgeLlGVakZ+ypO91O9
         FQmhbEf+SFpecqq7DaYCNmyNeV6v4XLkF+JmZHam7MlytO7IQxUiwuD0c3yJ8Zrp9GO6
         np0ZJteXc7RyKPMVFPN9VXziw13tsg14f8fbZ5Z2DXQOW6QZKx7CCxmcffDMTzt0v3/V
         znSDjHd3aE19BvG6XSPkLV+fzRwfAnbjM0fGoGVPhT2KhNwb0hzluLri7nvDPD00WTp0
         jUeuqxuze91CrhkKD0V5skTs3DzWB3e5XB+vFEAu+2r/+MnRep8XhT/751+JNna7fenP
         T4MQ==
X-Gm-Message-State: APjAAAWG4raR3/yapOITPoUt+z8FhBXQYt5++YmQOdu1qyJXVgq3xvgY
        BPHoeChSnbWAwSOm/qNMRekN41iKllYMU3GMB1M=
X-Google-Smtp-Source: APXvYqxgLeo3kasAOFvEKhdbiwn9S0V2UOlp7flp6xpFTvsglpKyQBKAVCmgoJ6MhjsDL/j/2xrTWqZEK0yvXRd4CXc=
X-Received: by 2002:a81:2e86:: with SMTP id u128mr4140438ywu.241.1551856172179;
 Tue, 05 Mar 2019 23:09:32 -0800 (PST)
MIME-Version: 1.0
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org> <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
 <20190208221239.GA199180@jra3> <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
 <20190214210652.GC9216@fieldses.org> <20190305214748.GD27437@fieldses.org>
In-Reply-To: <20190305214748.GD27437@fieldses.org>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Wed, 6 Mar 2019 09:09:21 +0200
Message-ID: <CAOQ4uxigRpjjni8nvYxCqeyTnr0Zf7Stj9h2+24_S9n4i0euYA@mail.gmail.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Jeremy Allison <jra@samba.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, Jeff Layton <jlayton@kernel.org>,
        samba-technical@lists.samba.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Ralph Boehme <slow@samba.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Mar 5, 2019 at 11:48 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Thu, Feb 14, 2019 at 04:06:52PM -0500, J. Bruce Fields wrote:
> > After this:
> >
> >       https://marc.info/?l=linux-nfs&m=154966239918297&w=2
> >
> > delegations would no longer conflict with opens from the same tgid.  So
> > if your threads all run in the same process and you're willing to manage
> > conflicts among your own clients, that should still allow you to do
> > multiple opens of the same file without giving up your lease/delegation.
> >
> > I'd be curious to know whether that works with Samba's design.
>
> Any idea whether that would work?
>
> (Easy?  Impossible?  Possible, but realistically the changes required to
> Samba would be painful enough that it'd be unlikely to get done?)
>

[CC Ralph Boehme]

I am not a samba team member, but seems to me that your proposal
fits samba design like a glove. With one smbd process per client connection,
with your proposal, opens (for read) from same smbd process will not break the
shared read lease from same client, so oplocks level II could be implemented
using kernel oplocks (new flavor).

IOW, can someone from samba team please elaborate on this quote
from samba wiki [1]: "Linux kernel oplocks don't provide the needed features.
(They don't even work correctly for oplocks...) ==> SMB-only feature."

[1] https://wiki.samba.org/index.php/Samba3/SMB2#new_concepts

I would like to use this opportunity to ask samba team members to raise
any (*) other pain points about missing or lacking Linux kernel interfaces.
I promise to use my time in LSF/MM 2019 to try and promote samba
needs among Linux filesystem developers.

Preferably, update the samba wiki page with wish list from Linux kernel,
but try to be more descriptive than "... don't provide the needed features".

(*) OK, not RichACLs. I know my own limitations.

Thanks,
Amir.
