Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846AbaKFPA7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Nov 2014 10:00:59 -0500
Message-ID: <545B8D1A.7060109@RedHat.com>
Date: Thu, 06 Nov 2014 10:00:42 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>,
        =?UTF-8?B?IlxcU3Ryw7Zzc2VyLCBCb2RvXCIgXCJA?=
	 =?UTF-8?B?cmVkaGF0LmNvbSI=?=
	<"bodo.stroesser\"@ts.fujitsu.com"@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
References: <61eb00$5dituo@dgate20u.abg.fsc.net>	<20141105210546.GH6513@fieldses.org>	<8B06D1E6480A6747B23FEC34909D2B5EA81B95F24C@ABGEX70E.FSC.NET> <20141106084741.40980d12@notabene.brown>
In-Reply-To: <20141106084741.40980d12@notabene.brown>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/05/2014 04:47 PM, NeilBrown wrote:
> Steve: you are maintainer for both (?).  Would you be able to make a
> libtirpc release soonish with the mentioned fix, then would you be happy for
> future nfs-utils to require at least that version?

Let me get the libtirpc fix in.. and then take a look at 
adding something to the aclocal/libtirpc.m4 requiring 
a particular version??

steved.
 
