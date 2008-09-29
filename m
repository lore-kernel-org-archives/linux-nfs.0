From: "howard chen" <howachen@gmail.com>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Mon, 29 Sep 2008 12:53:16 +0800
Message-ID: <b66ddc900809282153yb873d8ayf82f2a61eca9cc18@mail.gmail.com>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com>
	 <RTPCLUEXC2-PRDM3SOl0000001f@RTPMVEXC1-PRD.hq.netapp.com>
	 <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com>
	 <RTPCLUEXC2-PRDNXRPm0000003a@RTPMVEXC1-PRD.hq.netapp.com>
	 <b66ddc900809260857o39c4ef31h75af8e7eaf9448fc@mail.gmail.com>
	 <1222445161.10150.4.camel@localhost>
	 <b66ddc900809260913r6c009658p958d88aa2e1be99e@mail.gmail.com>
	 <RTPCLUEXC2-PRDIIZS20000003d@RTPMVEXC1-PRD.hq.netapp.com>
	 <b66ddc900809282121t6953e068n62870810f1d0874@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:15051 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbYI2ExQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Sep 2008 00:53:16 -0400
Received: by wa-out-1112.google.com with SMTP id v27so904533wah.21
        for <linux-nfs@vger.kernel.org>; Sun, 28 Sep 2008 21:53:16 -0700 (PDT)
In-Reply-To: <b66ddc900809282121t6953e068n62870810f1d0874-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

On Mon, Sep 29, 2008 at 12:21 PM, howard chen <howachen@gmail.com> wrote:
>
> Yes, tested, and same error... Also tried "no_root_squash"...
>
> Really have no idea what is going on...
>

Problem solved by adding the following line in fstab, according to
this site: http://www.linuxforums.org/forum/linux-networking/44779-nfs-permission-denied-error.html

nfsd /proc/fs/nfsd nfsd auto,defaults 0 0


This is really funny as I never have this option in my other NFS servers....

Anyone know the reason? Redhat's bug?

Thanks
