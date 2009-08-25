From: Stefan Egli <stefan.egli@gmail.com>
Subject: Re: NFS v3 cached directory content out of sync
Date: Tue, 25 Aug 2009 21:06:08 +0200
Message-ID: <d4098e2f0908251206o34590902u9a69aed32142d67e@mail.gmail.com>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <1250880591.27154.18.camel@heimdal.trondhjem.org>
	 <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
	 <1250962724.8143.29.camel@heimdal.trondhjem.org>
	 <d4098e2f0908221628kfa208c5wa3367f8fbde1c1c9@mail.gmail.com>
	 <d4098e2f0908240332k55ff2789r9aaa17cb5cd99cdf@mail.gmail.com>
	 <1251115893.6325.23.camel@heimdal.trondhjem.org>
	 <d4098e2f0908250901y359e51cewb1e22e7193922c52@mail.gmail.com>
	 <1251226809.25372.29.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:39720 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755639AbZHYTGI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 15:06:08 -0400
Received: by bwz19 with SMTP id 19so2097775bwz.37
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 12:06:09 -0700 (PDT)
In-Reply-To: <1251226809.25372.29.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2009 at 9:00 PM, Trond Myklebust wrote:
> Yes. The NFS client will cache mtime whether or not you do an 'ls'. I
> suspect the only reason for the 'ls' in that launchpad bug report, is to
> force an mtime update (and to fill the readdir cache).

Ok, interesting. I guess though that 'something' needs to read at least
a file in that particular directory for the directory content to be
cached, right? (i.e. either an 'ls' or some create/delete of a file?)

Cheers,
Stefan
