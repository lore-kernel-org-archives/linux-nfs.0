From: Shehjar Tikoo <shehjart-iP+wyIN8Xge1Z/+hSey0Gg@public.gmane.org>
Subject: Different rsize/wsize for different NFS server software
Date: Tue, 12 May 2009 16:44:01 +0530
Message-ID: <4A0959F9.1010107@zresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [12.204.100.226] ([12.204.100.226]:34921 "EHLO gluster.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754647AbZELMBH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2009 08:01:07 -0400
Received: from [115.108.23.204] (helo=[192.168.1.90])
	by gluster.com with esmtpa (Exim 4.69)
	(envelope-from <shehjart-iP+wyIN8Xge1Z/+hSey0Gg@public.gmane.org>)
	id 1M3pta-0003iw-5g
	for linux-nfs@vger.kernel.org; Tue, 12 May 2009 04:11:38 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All

I've been running some tests using the linux NFS3 client using the
in-kernel NFS server and the unfs3 project.

I see that the client mounts the in-kernel server with default
[rw]size values of 32k and the unfs3 server using [rw]size values
of 512k. Where is this difference coming from, because I do not
specify these different [rw]size value on the command line for mount.

The client kernel is Debian's 2.6.18-5-amd64 and the server kernel
is Fedora's 2.6.18-92.1.6.el5.

Thanks
Shehjar
