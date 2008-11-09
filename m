From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: NFS mount over IPv6 success
Date: Sun, 9 Nov 2008 17:41:32 +0100
Message-ID: <20081109164132.GA19615@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:38803 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755358AbYKIQlg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Nov 2008 11:41:36 -0500
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766] helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1KzDLx-0003b5-Q7
	for linux-nfs@vger.kernel.org; Sun, 09 Nov 2008 17:41:34 +0100
Received: from root by trofast.sesse.net with local (Exim 4.69)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1KzDLw-00056o-Kv
	for linux-nfs@vger.kernel.org; Sun, 09 Nov 2008 17:41:32 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm sure others have gotten this to work at some point, but it's finally
gotten to the point where I could get it to work myself, so I thought I could
share my success story:

 - Vanilla 2.6.28-rc3 client (2.6.26 also worked, although not with NFSv4)
 - Solaris 10 server
 - libtirpc from git (git://git.infradead.org/~steved/libtirpc.git)
 - IPv6-patched nfs-utils from git
   (git://git.linux-nfs.org/projects/cel/nfs-utils.git)

After recompiling (actually making Debian packages of) the client software,
it was just a matter of mounting. 2.6.26 had some issues with IPv6 address
literals -- only DNS worked -- but 2.6.28-rc3 did both just fine.

I haven't done extensive testing, but this looks pretty good :-) Now I'm just
waiting for the server support to get ready in the same way, and then for
everything to trickle into mainline.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
