From: "Dr. Tilmann Bubeck" <t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>
Subject: Is order for "exportfs -r" and rpc.mountd important?
Date: Fri, 28 Nov 2008 15:41:38 +0100
Message-ID: <200811281541.39272.t.bubeck@reinform.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw1.reinform.de ([82.141.45.9]:51358 "EHLO
	mail-out.dmz.loef.reinform.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751996AbYK1Owf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Nov 2008 09:52:35 -0500
Received: from postfix.loef.reinform.de (postfix.loef.reinform.de [10.1.1.39])
	by mail-out.dmz.loef.reinform.de (Postfix) with ESMTP id 5DDD51485DE
	for <linux-nfs@vger.kernel.org>; Fri, 28 Nov 2008 15:41:42 +0100 (CET)
Received: from mail.reinform.de (mail.reinform.de [82.141.45.14])
	by postfix.loef.reinform.de (Postfix) with ESMTP id 122841BC14
	for <linux-nfs@vger.kernel.org>; Fri, 28 Nov 2008 15:41:42 +0100 (CET)
Received: from loeffel.loef.reinform.de (loeffel.loef.reinform.de [10.1.1.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.reinform.de (Postfix) with ESMTPSA id C76CF63728
	for <linux-nfs@vger.kernel.org>; Fri, 28 Nov 2008 15:41:41 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to manual page "exportfs -r" has two modes: legacy and new. Fedora 
10 seems to use the new mode and mounts /proc/fs/nfsd.

But they use the following order in /etc/init.d/nfs:
  exportfs -r
  rpc.mountd

This results in /proc/fs/nfsd/exports having all obsolete entries 
from /var/lib/nfs/rmtab which causes a lot of trouble with stale NFS file 
handles. This seems to be wrong according to "man exportfs" in new mode.

If I change the order to
  rpc.mountd
  exportfs -r

then everything is OK and /proc/fs/nfsd/exports only contains the info 
from /etc/exports and not all stale clients. This seems to be correct 
according to "man exportfs" in new mode.

Questions: is this behaviour a bug or at least bad? Shouldn't exportfs being 
changed, so that when it detects "new" mode it will never feed rmtab into the 
kernel and rely upon rpc.mountd answering the kernels questions as stated 
in "man exportfs"?

If yes, then the order or the programs is irrelevant.
If not, should the order of the programs be reversed in Fedora?

Thanks
 Till


-- 
+-------+-------------------------------------------------------------+
|       | dr. tilmann bubeck               reinform medien- und       |
|       |                                  informationstechnologie AG |
| rein  | fon  : +49 (711) 7 82 76-52      loeffelstr. 40             |
| form  | fax  : +49 (711) 7 82 76-46      70597 stuttgart / germany  |
|    AG | cell.: +49 (172) 8 84 29 72      fon: +49 (711) 75 86 56-10 |
|       | email: t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org      http://www.reinform.de     |
|       +-------------------------------------------------------------+
|       | pflichtangaben nach paragraph 80, AktG:                     |
|       | reinform medien- und informationstechnologie AG, stuttgart  |
|       | handelsregister stuttgart, HRB 23001                        |
|       | vorstand:     dr. tilmann bubeck (vorsitz), dr. tommy kuhn  |
|       | aufsichtsrat: frank stege (vorsitz)                         |
+-------+-------------------------------------------------------------+
