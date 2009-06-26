From: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Subject: Reference to file size in nfsd_create_v3
Date: Fri, 26 Jun 2009 14:40:12 +0530
Message-ID: <4A449074.6060600@gluster.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from saturn.datasyncintra.net ([208.88.241.29]:60202 "EHLO
	saturn.datasyncintra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885AbZFZJIt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jun 2009 05:08:49 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by saturn.datasyncintra.net (Postfix) with ESMTP id 7787D85F637
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2009 04:08:52 -0500 (CDT)
Received: from saturn.datasyncintra.net ([127.0.0.1])
	by localhost (saturn.datasyncintra.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0jJE--c-gA2T for <linux-nfs@vger.kernel.org>;
	Fri, 26 Jun 2009 04:08:52 -0500 (CDT)
Received: from [192.168.1.91] (unknown [122.166.102.221])
	(Authenticated sender: shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org)
	by saturn.datasyncintra.net (Postfix) with ESMTP id 483D785F61F
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2009 04:08:50 -0500 (CDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All

I am looking at the fs/nfsd/vfs.c:nfsd_create_v3 function.
In there, a comment says:
"furthermore, if the size is nonzero, we should ignore it
according to spec!"

Could someone please point out the section in RFC1813 where this
  particular point is specified?

Thanks
Shehjar
