From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Mon, 14 Oct 2002 14:45:33 +0400 (MSD)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200210141045.OAA10901@sex.inr.ac.ru>
References: <20021013.231534.08939486.davem@redhat.com>
Mime-Version: 1.0
Cc: neilb@cse.unsw.edu.au, taka@valinux.co.jp,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20021013.231534.08939486.davem@redhat.com> from "David S. Miller" at Oct 13, 2 11:15:34 pm
List-ID: <nfs.lists.sourceforge.net>

Hello!

> Alexey is working on this, or at least he was. :-)
> (Alexey this is about the UDP cork changes)

I took two patches of the batch:

va10-hwchecksum-2.5.36.patch
va11-udpsendfile-2.5.36.patch

I did not worry about the rest i.e. sunrpc/* part.

Alexey
