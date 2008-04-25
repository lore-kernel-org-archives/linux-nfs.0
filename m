From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: retry= is additive with the text-based mount interface
Date: Fri, 25 Apr 2008 10:05:35 +0200
Message-ID: <20080425080535.GA4999@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:56087 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760707AbYDYIFh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 04:05:37 -0400
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766] helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1JpIw3-0005Of-VN
	for linux-nfs@vger.kernel.org; Fri, 25 Apr 2008 10:05:36 +0200
Received: from root by trofast.sesse.net with local (Exim 4.69)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1JpIw3-0001J6-Dj
	for linux-nfs@vger.kernel.org; Fri, 25 Apr 2008 10:05:35 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

(Via a user bug report)

It seems retry= is now additive with the text-based mount interface. In
particular, "mount -o retry=0" still gives a two-minute timeout. Is this
intentional?

/* Steinar */
-- 
Homepage: http://www.sesse.net/
