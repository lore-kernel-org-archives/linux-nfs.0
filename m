Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:42499 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751232Ab1AABDu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Dec 2010 20:03:50 -0500
Date: 31 Dec 2010 20:03:49 -0500
Message-ID: <20110101010349.12974.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux@horizon.com, Trond.Myklebust@netapp.com
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
In-Reply-To: <1293769968.32633.19.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

> ...and your point would be that an exponentially increasing addition to
> the existing number of tests is an acceptable tradeoff in a situation
> where the >99.999999999999999% case is that of sane servers with no
> looping? I don't think so...

1) Look again; it's O(1) work per entry, or O(n) work for an n-entry
   directory.  And O(1) space.  With very small constant factors, and
   very little code.  The only thing exponentially increasing is the
   interval at which you save the current cookie for future comparison.
2) You said it *was* a problem, so it seemed worth presenting a
   practical solution.  If you don't think it's worth it, I'm not
   going to disagree.  But it's not impossible, or even difficult.
