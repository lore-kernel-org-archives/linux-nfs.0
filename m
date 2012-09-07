Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 5350504D.static.ziggozakelijk.nl ([83.80.80.77]:16524 "EHLO
	ns2.tasking.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932400Ab2IGOdr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Sep 2012 10:33:47 -0400
Received: from leonino.tasking.nl (nl-fg300a-1-dmz.tasking.nl [172.16.1.8])
	by ns2.tasking.nl (8.14.5/8.14.5) with ESMTP id q87EXkYs001633
	(version=TLSv1/SSLv3 cipher=DHE-DSS-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 7 Sep 2012 16:33:46 +0200 (MEST)
Received: from lahti.tasking.nl (lahti.tasking.nl [172.17.2.45])
	by leonino.tasking.nl (8.14.5/8.14.5) with ESMTP id q87EXkKl009064
	for <linux-nfs@vger.kernel.org>; Fri, 7 Sep 2012 16:33:46 +0200 (MEST)
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0
Reply-To: dick.streefland@altium.nl (Dick Streefland)
References: <1315610322.17611.112.camel@lade.trondhjem.org> <20111020190334.GA22772@hostway.ca> <20120301225524.GB27595@hostway.ca> <20120302002511.GA4495@hostway.ca> <20120302184918.GA20702@hostway.ca> <loom.20120905T093214-245@post.gmane.org> <loom.20120905T093214-245@post.gmane.org> <4FA345DA4F4AE44899BD2B03EEEC2FA908F86381@SACEXCMBX04-PRD.hq.netapp.com> <6cb9.5049fd40.b47c1@altium.nl> <6cb9.5049fd40.b47c1@altium.nl> <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E302@SACEXCMBX04-PRD.hq.netapp.com>
From: dick.streefland@altium.nl (Dick Streefland)
Subject: Re: [3.2.5] NFSv3 CLOSE_WAIT hang
Content-Type: text/plain; charset=us-ascii
Message-ID: <447c.504a05c9.dd0a9@altium.nl>
Date: Fri, 07 Sep 2012 14:33:45 -0000
From: rnews@altium.nl
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
| > I can easily reproduce the hang on the latest kernel (eeea3ac912) with my
| > script (http://permalink.gmane.org/gmane.linux.nfs/51833).
| 
| On TCP?

No, on UDP (mount options are in that first email).

| > With this change, it doesn't hang:
| 
| It doesn't matter as long as that change is wrong. That code _is_ needed for TCP.
| 
| Now if UDP is broken, then we can talk about a fix for that issue, but that's not going to be the one you propose.

OK, fine with me. My proposal to revert this change was only based on
the remark in the comment that it is not strictly needed. So we need
to differentiate between UDP and TCP then?

-- 
Dick

