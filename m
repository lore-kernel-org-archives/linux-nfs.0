From: Arnd Bergmann <arnd@arndb.de>
Subject: nfs shared mmap performance regression against 2.6.23
Date: Tue, 29 Apr 2008 17:18:09 +0200
Message-ID: <200804291718.10462.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: Trond.Myklebust@netapp.com, brad.benton@us.ibm.com,
	jroth@linux.vnet.ibm.com, mkistler@us.ibm.com, adetsch-xuelUoVDAHHQT0dZR+AlfA@public.gmane.org,
	lxie@us.ibm.com, mijo@linux.vnet.ibm.com,
	gerhard.stenzel-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, uweigand-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	brokensh@us.ibm.com, hannsj_uhl-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, brianh-tEXmvtCZX7AybS5Ee8rs3A@public.gmane.org,
	tstaudt-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, linux-mm@kvack.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:61443 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbYD2PTO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2008 11:19:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

We had an application writer report a performance regression between
2.6.23 and later kernels that we ultimately tracked down to your
patch 94387fb1aa, "NFS: Add the helper nfs_vm_page_mkwrite". It turns
out the application was accidentally using a writable shared mmap
between two processes on an NFS mount instead of tmpfs.

The setup is fixed now, but I'm still surprised by the 7x slowdown
caused by this patch for application runtime when the mmap is shared
between two processes writing to it. If there is only one process
that maps the file, there is no measureable slowdown.

Is that an expected side-effect of your patch, or something that
should not have happened?

	Arnd <><
