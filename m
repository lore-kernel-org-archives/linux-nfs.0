Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:36459 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041Ab1BVNbP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Feb 2011 08:31:15 -0500
Received: from [96.31.168.206] (helo=mail.parallels.com)
	by mx2.parallels.com with esmtps (TLSv1:AES128-SHA:128)
	(Exim 4.72)
	(envelope-from <rlandley@parallels.com>)
	id 1PrsKh-0000tU-06
	for linux-nfs@vger.kernel.org; Tue, 22 Feb 2011 08:31:15 -0500
Message-ID: <4D63BAA0.3090505@parallels.com>
Date: Tue, 22 Feb 2011 07:31:12 -0600
From: Rob Landley <rlandley@parallels.com>
To: <linux-nfs@vger.kernel.org>
Subject: CACHE_NEW_EXPIRY is 120, nextcheck initialized to 30*60=1800?
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In net/sunrpc/cache.c line 416 or so (function cache_clean()) there's
this bit:

else {
        current_index = 0;
        current_detail->nextcheck = seconds_since_boot()+30*60;
}

The other uses of seconds_since_boot() add CACHE_NEW_EXPIRY (which is
120).  This is A) more than ten times that, B) a magic inline constant.

Is there a reason for this?  (Some subtle cache lifetime balancing thing?)

Rob
