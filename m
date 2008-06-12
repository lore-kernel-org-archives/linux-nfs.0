From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [NFS] Problem with stateid renewal
Date: Thu, 12 Jun 2008 16:50:01 -0700
Message-ID: <1213314601.3907.51.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS List <nfs@lists.sourceforge.net>,
	NFS V4 Mailing List <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52676 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757111AbYFLXrA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 19:47:00 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K6wVO-0005M6-K1
	for linux-nfs@vger.kernel.org; Fri, 13 Jun 2008 09:46:58 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm observing an interesting stateid problem on a 2.6.18 based kernel to
an AIX server. I've added some printks to track stateids and a couple
other things, and see the following sequence:

01: _nfs4_do_open name=1GB57
02: decode_open                     , stateid: 00000001:48295ae2 00000008 004e8042
03: encode_open_confirm             , stateid: 00000001:48295ae2 00000008 004e8042
04: decode_open_confirm             , stateid: 00000002:48295ae2 00000008 004e8042
05: nfs4_open_confirm_done          , stateid: 00000002:48295ae2 00000008 004e8042
06: update_open_stateid             , stateid: 00000002:48295ae2 00000008 004e8042
07: nfs4_copy_stateid open          , stateid: 00000002:48295ae2 00000008 004e8042
08: encode_setattr                  , stateid: 00000002:48295ae2 00000008 004e8042
09: encode_stateid                  , stateid: 00000002:48295ae2 00000008 004e8042
10: nfs4_renew_state now: 627063 last: 547074 lease: 120000 expires: 667074
11: nfs4_renew_done scheduled state recovery (no wait) task->tk_status=NFS4ERR_EXPIRED (-10011) now=627296
12: reclaimer at restart_loop nfs4_renew_done NFS4ERR_EXPIRED
13: encode_stateid skipped same stateid 7510 times
14: decode_open                     , stateid: 00000001:48295ae2 00000008 00508042
15: encode_stateid not last decoded , stateid: 00000002:48295ae2 00000008 004e8042
16: encode_open_confirm             , stateid: 00000001:48295ae2 00000008 00508042
17: encode_stateid not last decoded , stateid: 00000002:48295ae2 00000008 004e8042
18: decode_open_confirm             , stateid: 00000002:48295ae2 00000008 00508042
19: nfs4_open_confirm_done          , stateid: 00000002:48295ae2 00000008 00508042
20: nfs4_open_recover_helper        , stateid: 00000002:48295ae2 00000008 00508042
21: update_open_stateid             , stateid: 00000002:48295ae2 00000008 00508042
22: reclaimer at out
23: nfs4_copy_stateid open          , stateid: 00000002:48295ae2 00000008 00508042
24: encode_stateid                  , stateid: 00000002:48295ae2 00000008 00508042
25: encode_stateid skipped same stateid 8510 times
26: encode_close                    , stateid: 00000002:48295ae2 00000008 00508042
27: nfs4_put_open_state             , stateid: 00000002:48295ae2 00000008 00508042

What seems to be happening is that a state requires renewal (at line
10), the renewal fails with NFS4ERR_EXPIRED (line 11) so a new open is
issued as part of recovery (line 14). During the time the open recovery
is in progress, two writes occur (line 15 and line 17) using the old
expired stateid. Finally, the open recovery completes and the new
stateid is used for the rest of the writes (line 24 and line 25).

One question is why the open state is expiring, it appears that is
expires significantly before it is expected to (expires: 667074, now:
627296). Also, should those two writes actually occur while open
recovery is in progress? If so, and if they fail, shouldn't they be
retried?

Any suggestions on additional debug? I'd like to avoid enabling all
debug messages since they would flood the log.

Thanks

Frank




-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

