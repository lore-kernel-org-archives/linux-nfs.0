From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Mon, 14 Oct 2002 03:48:53 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021014.034853.77257674.davem@redhat.com>
References: <20021013.231534.08939486.davem@redhat.com>
	<200210141045.OAA10901@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, taka@valinux.co.jp,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200210141045.OAA10901@sex.inr.ac.ru>
List-ID: <nfs.lists.sourceforge.net>

   From: kuznet@ms2.inr.ac.ru
   Date: Mon, 14 Oct 2002 14:45:33 +0400 (MSD)

   I took two patches of the batch:
   
   va10-hwchecksum-2.5.36.patch
   va11-udpsendfile-2.5.36.patch
   
   I did not worry about the rest i.e. sunrpc/* part.

Neil and the NFS folks can take care of those parts
once the generic UDP parts are in.

So, no worries.
