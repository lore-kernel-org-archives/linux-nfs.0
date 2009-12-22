From: Harald Dunkel <harald.dunkel@aixigo.de>
Subject: 2.6.29.6: nfsd: non-standard errno: -9
Date: Tue, 22 Dec 2009 12:50:24 +0100
Message-ID: <4B30B280.50907@aixigo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([195.14.232.227]:15434 "EHLO gate1.ac.aixigo.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751075AbZLVMWo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Dec 2009 07:22:44 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I get billions of error messages in kern.log syaing

:
:
Dec 22 10:44:55 nasl002a kernel: [ 3676.852579] nfsd: non-standard errno: -9
Dec 22 10:44:55 nasl002a kernel: [ 3676.906972] nfsd: non-standard errno: -9
Dec 22 10:44:55 nasl002a kernel: [ 3676.917499] nfsd: non-standard errno: -9
Dec 22 10:44:55 nasl002a kernel: [ 3676.917742] nfsd: non-standard errno: -9
Dec 22 10:44:55 nasl002a kernel: [ 3676.917753] nfsd: non-standard errno: -9
Dec 22 10:44:55 nasl002a kernel: [ 3676.917764] nfsd: non-standard errno: -9
Dec 22 10:44:55 nasl002a kernel: [ 3676.959585] nfsd: non-standard errno: -9
Dec 22 10:44:55 nasl002a kernel: [ 3676.959621] nfsd: non-standard errno: -9
Dec 22 10:44:55 nasl002a kernel: [ 3676.980210] nfsd: non-standard errno: -9
Dec 22 10:44:55 nasl002a kernel: [ 3676.980613] nfsd: non-standard errno: -9
:
:

This is (supposed to be) NFSv4. The clients are running SunOS 5.10.

Google doesn't reveal anything, so I wonder whether you have an
idea?


Any helpful comments would be highly appreciated.


Regards

Harri
