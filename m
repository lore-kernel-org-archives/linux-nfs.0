Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f44.google.com ([209.85.215.44]:41012 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbaEAIlK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 04:41:10 -0400
Date: Thu, 1 May 2014 10:40:45 +0200
From: Johan Hovold <jhovold@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        Mark Lord <mlord@pobox.com>, Albert Fluegel <af@muc.de>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        stable@vger.kernel.org
Subject: [stable] linux-3.14 nfsd regression
Message-ID: <20140501084045.GA4766@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Greg,

I noticed that v3.14 broke my development system which relies on nfsroot
for embedded targets, but soon found Bruce's fix (which has now been in
Linus' tree for a while):

	082f31a2169b ("nfsd: revert v2 half of "nfsd: don't return high
		       mode bits")

The fix did not make it into v3.14.2 (and I didn't find it in your
stable queue), so I thought I'd send a reminder.

Thanks,
Johan
