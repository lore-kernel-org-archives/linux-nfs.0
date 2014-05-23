Return-Path: linux-nfs-owner@vger.kernel.org
Received: from a.ns.miles-group.at ([95.130.255.143]:47834 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbaEWNqa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 09:46:30 -0400
Message-ID: <537F5133.8020700@nod.at>
Date: Fri, 23 May 2014 15:46:27 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com, NeilBrown <neilb@suse.de>,
        LKML <linux-kernel@vger.kernel.org>, David Gstir <david@sigma-star.at>
Subject: Re: NFS issue while copying huge file
References: <CAFLxGvw_7=AuBqxNhAHpQAXq2aTqc8Afa6Z62=YCsFXcJx0Hug@mail.gmail.com> <CAFLxGvxm43MaOqv1JQ8vxkn4s50uHZ8Js6A-Ec+O_sjvFszehQ@mail.gmail.com> <20140523115655.GA14074@fieldses.org> <537F40C0.7030403@nod.at> <20140523133907.GJ25423@fieldses.org>
In-Reply-To: <20140523133907.GJ25423@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am 23.05.2014 15:39, schrieb J. Bruce Fields:
> And like the lock contention may be in xfs....  So ideally you'd get
> someone who knows the CentOS/RHEL6 xfs code to look at it first.

I saw this coming. ;)

Thanks,
//richard
