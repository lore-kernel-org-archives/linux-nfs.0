From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Text-based mount interface breaking non-UDP mounts
Date: Wed, 23 Apr 2008 23:49:29 +0200
Message-ID: <20080423214929.GA24387@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:48101 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754554AbYDWVtg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2008 17:49:36 -0400
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766] helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1JomqL-00018H-K9
	for linux-nfs@vger.kernel.org; Wed, 23 Apr 2008 23:49:34 +0200
Received: from root by trofast.sesse.net with local (Exim 4.69)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1JomqH-0006Lf-MG
	for linux-nfs@vger.kernel.org; Wed, 23 Apr 2008 23:49:29 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I've gotten a few bug reports lately that if UDP is blocked at the server,
NFS mounts (even with -o tcp) fail. git bisect shows that the culprit is
the change "Get rid of the "-i" option for mount.nfs[4] and always use the
text-based mount(2) system call for kernel version 2.6.23 and later." -- in
other words, the bug is specific to the text interface. Does anyone know why
this would be the case?

/* Steinar */
-- 
Homepage: http://www.sesse.net/
