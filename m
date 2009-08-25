From: Stefan Egli <stefan.egli@gmail.com>
Subject: Re: NFS v3 cached directory content out of sync
Date: Tue, 25 Aug 2009 21:45:11 +0200
Message-ID: <d4098e2f0908251245y4ed4a93bycf1a8cf902b18d84@mail.gmail.com>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <d4098e2f0908240332k55ff2789r9aaa17cb5cd99cdf@mail.gmail.com>
	 <1251115893.6325.23.camel@heimdal.trondhjem.org>
	 <d4098e2f0908250901y359e51cewb1e22e7193922c52@mail.gmail.com>
	 <1251226809.25372.29.camel@heimdal.trondhjem.org>
	 <d4098e2f0908251206o34590902u9a69aed32142d67e@mail.gmail.com>
	 <1251227539.25372.35.camel@heimdal.trondhjem.org>
	 <d4098e2f0908251219w42340c9ak4538a22f8d7391b6@mail.gmail.com>
	 <1251228350.25372.36.camel@heimdal.trondhjem.org>
	 <5FC6E83A-4D26-4A77-B3F0-E34A9E97E9B5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:42973 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756046AbZHYTpK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 15:45:10 -0400
Received: by fxm17 with SMTP id 17so2419302fxm.37
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 12:45:11 -0700 (PDT)
In-Reply-To: <5FC6E83A-4D26-4A77-B3F0-E34A9E97E9B5@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Mates! I've seen those manuals but the bug I'm chasing doesn't
seem to be documented ;)

Just now that I got your attention :) one final clarification question:
 * the attribute cache (==metadata cache) is part of the nfs client code
 * the date (=file content) cache would be the normal linux caching

Am I on the right track there?

Cheers,
Stefan
