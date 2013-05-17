Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw1.transmode.se ([195.58.98.146]:61489 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756286Ab3EQOil (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 May 2013 10:38:41 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id A023C25801B
	for <linux-nfs@vger.kernel.org>; Fri, 17 May 2013 16:38:39 +0200 (CEST)
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Subject: Is the code stateid_generation_after()in legal C?
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Message-ID: <OFD54C462E.9A1446D0-ONC1257B6E.004D4190-C1257B6E.00507192@transmode.se>
Date: Fri, 17 May 2013 16:38:39 +0200
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

static bool stateid_generation_after(stateid_t *a, stateid_t *b)
{
        return (s32)a->si_generation - (s32)b->si_generation > 0;
}

overflow is undefined for signed integers and gcc uses that nowadays.
Not sure if that can affect the above code?

 Jocke
