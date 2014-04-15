Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:40662 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbaDOAVK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2014 20:21:10 -0400
Message-ID: <534C7B70.9000500@candelatech.com>
Date: Mon, 14 Apr 2014 17:21:04 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Question on nfs-utils patch for 'keyctl_invalidate'.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It seems that key_invalidate is only available in quite recent
keyutils packages.

Anyone know if there is a relatively simple way to implement
the same behaviour using older keyutils packages?

The reason I ask is that I recently updated to latest nfs-utils
package and how build fails on many of my older systems...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

