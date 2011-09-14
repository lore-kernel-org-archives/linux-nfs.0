Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:44528 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812Ab1ING2B convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Sep 2011 02:28:01 -0400
From: "Tim" <supertimothy@web.de>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
References: <000801cc71f9$9cc45650$d64d02f0$@web.de> <20110913124440.GA22118@fieldses.org> <4E6FE4D1.20209@web.de> <20110914023709.GA28357@fieldses.org>
In-Reply-To: <20110914023709.GA28357@fieldses.org>
Subject: AW: nfsv4 and gracetime / leasetime grace_period
Date: Wed, 14 Sep 2011 08:27:59 +0200
Message-ID: <000001cc72a7$73151c50$593f54f0$@web.de>
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>> /proc/sys/fs/nfs/nlm_grace_period
>> This is the part I don't understand what it is for. I read it has to 
>> be shrunk too (I set it to 10 - which works). Standard value is 0.

> NLM (used with NFSv2/v3) works a little differently: instead of the clients polling at regular intervals, the server calls back to the clients to notify them that it has rebooted.  But there's still this grace period, which is the length of time the NLM server waits for the clients to act on the notifications by sending lock reclaims.

> It affects v4 as well, because the v4 server can't end its grace period before the NLM server does: if it did, v4 clients could rush in and start doing new locks before v2/v3 clients had the chance to reclaim all of theirs.

So if I only use NFSv4, I can set this to 1 second? Or would 0 be better?

