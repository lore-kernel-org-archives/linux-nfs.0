From: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Subject: Short-reads on NFS client
Date: Thu, 30 Jul 2009 22:12:31 +0530
Message-ID: <4A71CD77.2000505@gluster.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from saturn.datasyncintra.net ([208.88.241.29]:46434 "EHLO
	saturn.datasyncintra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbZG3Qjd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2009 12:39:33 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by saturn.datasyncintra.net (Postfix) with ESMTP id 709D477B325
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2009 11:39:34 -0500 (CDT)
Received: from saturn.datasyncintra.net ([127.0.0.1])
	by localhost (saturn.datasyncintra.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id INqHaB23jDpz for <linux-nfs@vger.kernel.org>;
	Thu, 30 Jul 2009 11:39:33 -0500 (CDT)
Received: from [192.168.1.91] (unknown [122.166.102.221])
	(Authenticated sender: shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org)
	by saturn.datasyncintra.net (Postfix) with ESMTP id 336797D3281
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2009 11:39:32 -0500 (CDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All

Is there ever a possibility that a read syscall over linux nfs client
will return a short read? I think a short read is what I am observing
on our system with unfs3 as the NFS server. I've instrumented the
server and it seems to be returning the correct amount of data.

Is there any way I can debug this further?

I am running the  2.6.18-92.el5 kernel. The tool I am using is fileop
that is part of the iozone package. The original problem with the test
is that it outputs "Data mis-compare" error messages which means that
while doing a byte-to-byte comparison of what it wrote against the
data it read back from the file, it fails to see same contents as
written by it. On further hacking a bit with the code, I see that it
tries to compare X bytes in its buffer with Y bytes read from the
file, assuming that X will always be equal to Y. Is this assumption
supposed to hold for linux NFS client reads?

Thanks
Shehjar
