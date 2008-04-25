From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: The text-based mount interface doesn't support -s (--sloppy)
Date: Fri, 25 Apr 2008 10:11:14 +0200
Message-ID: <20080425081114.GA5148@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:52688 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbYDYILR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 04:11:17 -0400
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766] helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1JpJ1X-0005zJ-4g
	for linux-nfs@vger.kernel.org; Fri, 25 Apr 2008 10:11:15 +0200
Received: from root by trofast.sesse.net with local (Exim 4.69)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1JpJ1W-0001LN-Ho
	for linux-nfs@vger.kernel.org; Fri, 25 Apr 2008 10:11:14 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Another user-reported regression. -s used to work, but since 1.1.2 it does
not, probably due to the text-based interface somehow:

  fugl:~> sudo mount.nfs 10.0.0.10:/store /store -s -o rw,asdfasdf   
  mount.nfs: an incorrect mount option was specified

/* Steinar */
-- 
Homepage: http://www.sesse.net/
