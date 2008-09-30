From: "howard chen" <howachen@gmail.com>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Tue, 30 Sep 2008 21:51:08 +0800
Message-ID: <b66ddc900809300651i11d07caudd32831d6954f02d@mail.gmail.com>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com>
	 <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com>
	 <RTPCLUEXC2-PRDNXRPm0000003a@RTPMVEXC1-PRD.hq.netapp.com>
	 <b66ddc900809260857o39c4ef31h75af8e7eaf9448fc@mail.gmail.com>
	 <1222445161.10150.4.camel@localhost>
	 <b66ddc900809260913r6c009658p958d88aa2e1be99e@mail.gmail.com>
	 <RTPCLUEXC2-PRDIIZS20000003d@RTPMVEXC1-PRD.hq.netapp.com>
	 <b66ddc900809282121t6953e068n62870810f1d0874@mail.gmail.com>
	 <b66ddc900809282153yb873d8ayf82f2a61eca9cc18@mail.gmail.com>
	 <20080929172630.GB23212@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:16814 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbYI3NvI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Sep 2008 09:51:08 -0400
Received: by wa-out-1112.google.com with SMTP id v27so10439wah.21
        for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2008 06:51:08 -0700 (PDT)
In-Reply-To: <20080929172630.GB23212@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Tue, Sep 30, 2008 at 1:26 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> It looks like nfsd is supposed to be mounted on load of the nfsd module,
> by a line in /etc/modprobe.d/modprobe.conf.
>
> (Maybe you built a new kernel with nfsd built-in instead of built as a
> module?)
>
> But I thought nfs-utils was supposed to fall back on old behavior when
> the nfsd filesystem wasn't found.


Are there any related docs I should read?

As mentioned before, the server was working before the reboot, really
don't understand why it behave in this way...Need to find out the
reason.

THanks!
