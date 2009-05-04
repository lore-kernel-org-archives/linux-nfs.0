From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: next: build fails at fs/lockd/svclock.c
Date: Mon, 4 May 2009 17:23:26 +0400
Message-ID: <a4423d670905040623q48eb552ft3bd107d6aa71d63b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-next <linux-next@vger.kernel.org>,
	Felix Blyakher <felixb@sgi.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:50824 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbZEDNX2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2009 09:23:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

Randconfig fails like this

fs/lockd/svclock.c: In function 'nlmsvc_freegrantargs':
fs/lockd/svclock.c:330: error: implicit declaration of function
'locks_release_private'

caused by a9e61e25f9d2
(lockd: call locks_release_private to cleanup per-filesystem state)


# CONFIG_FILE_LOCKING is not set
CONFIG_LOCKD=y
