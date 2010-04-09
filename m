From: Arnaud Giersch <arnaud.giersch-T9cNH8bv7N6Vy8wrSkPSsihWMY4UYrEW@public.gmane.org>
Subject: BUG: cannot acquire lock twice with NFSv4
Date: Fri, 09 Apr 2010 15:05:14 +0200
Message-ID: <wwer5mo3hf9.fsf@powwow.iut-bm.univ-fcomte.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from messager.iut-bm.univ-fcomte.fr ([194.57.86.195]:48953 "EHLO
	messager.iut-bm.univ-fcomte.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751223Ab0DINPO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Apr 2010 09:15:14 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by messager.iut-bm.univ-fcomte.fr (Postfix) with ESMTP id B6EED2B4BB
	for <linux-nfs@vger.kernel.org>; Fri,  9 Apr 2010 15:05:16 +0200 (CEST)
Received: from messager.iut-bm.univ-fcomte.fr ([127.0.0.1])
	by localhost (messager.iut-bm.univ-fcomte.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Xa3aYu+-kjdl for <linux-nfs@vger.kernel.org>;
	Fri,  9 Apr 2010 15:05:14 +0200 (CEST)
Received: from powwow.iut-bm.univ-fcomte.fr (powwow.iut-bm.univ-fcomte.fr [193.52.61.133])
	by messager.iut-bm.univ-fcomte.fr (Postfix) with ESMTPS id B07522B4B7
	for <linux-nfs@vger.kernel.org>; Fri,  9 Apr 2010 15:05:14 +0200 (CEST)
Received: from giersch by powwow.iut-bm.univ-fcomte.fr with local (Exim 4.71)
	(envelope-from <arnaud.giersch-T9cNH8bv7N6Vy8wrSkPSsihWMY4UYrEW@public.gmane.org>)
	id 1O0Dta-0006R8-JA
	for linux-nfs@vger.kernel.org; Fri, 09 Apr 2010 15:05:14 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I tried to experiment with NFSv4 to mount my home directory, but
bogofilter started to fail.
I was able to produce the following minimal test case, by writing a
program that:

  1. opens a first file, and acquires read lock on it ;
  2. opens a second file, and acquires read lock on it ;
  3. releases locks, and closes files.

Both opened files are of course on the NFS mount.  On the first run, all
seems to be fine.  On the second (and subsequent) runs, the lock is
refused at step 2 with errno=37 (ENOLCK, No locks available).

Steps 1 and 2 look like the following (I can provide the full source
code if needed):

    int fd = open(filename, O_RDONLY);
    struct flock lock = {
        .l_type = F_RDLCK,
        .l_whence = SEEK_SET,
        .l_start = 0,
        .l_len = 0,
    }
    fcntl(fd, F_SETLK, &lock);

Umounting and re-mounting the directory make the first run work again as
expected.  There is no problem with NFSv3, only with v4.

I first experimented the problem with the Debian kernels 2.6.26-2-amd64
for the server, and 2.6.33-2-amd64 for the client.
I also tried the latest kernel (2.6.34-rc3), either as client or as server
with no luck.

Regards,

        Arnaud Giersch

