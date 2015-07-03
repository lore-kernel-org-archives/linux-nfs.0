Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:33562 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443AbbGCNtm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 09:49:42 -0400
Received: by igcur8 with SMTP id ur8so144516919igc.0
        for <linux-nfs@vger.kernel.org>; Fri, 03 Jul 2015 06:49:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Neil Brown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: RE: [PATCH] SUNRPC: handle -EAGAIN from socket writes better.
Date: Fri,  3 Jul 2015 09:49:37 -0400
Message-Id: <1435931379-6654-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <20150629142623.5afc0e6d@noble>
References: <20150629142623.5afc0e6d@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

There should already be a handler for ENOBUFS in call_status, but
I can see that it has a couple of flaws. What say we try to fix that
instead?

Cheers
  Trond

-- 
2.4.3

