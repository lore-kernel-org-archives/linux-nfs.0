From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Version check in aclocal/kerberos.m5
Date: Sun, 30 Mar 2008 12:31:59 +0200
Message-ID: <20080330103159.GA4003@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:55177 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbYC3KcE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Mar 2008 06:32:04 -0400
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766] helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1JfupU-0000TV-NI
	for linux-nfs@vger.kernel.org; Sun, 30 Mar 2008 12:32:00 +0200
Received: from root by trofast.sesse.net with local (Exim 4.69)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1JfupT-000132-W5
	for linux-nfs@vger.kernel.org; Sun, 30 Mar 2008 12:32:00 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Does anyone know where the version check in aclocal/kerberos.m5 come from? I
need to patch it (Debian's krb5-config --version gives a version like
"1.6.3-beta1-debian", and it doesn't manage to strip away the -beta part),
but it's not clear to me who upstream really is. (At least I've seen the code
in several other projects.)

Any ideas?

/* Steinar */
-- 
Homepage: http://www.sesse.net/
