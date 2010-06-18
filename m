From: "Dr. Md. Aminul Islam Khan" <aikhan_lab-jH00EaABlX1eoWH0uzbU5w@public.gmane.org>
Subject: Unable to unlock file in NFS4
Date: Fri, 18 Jun 2010 17:32:13 +0600
Message-ID: <1276860733.7481.27.camel@aikhan-laptop>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.bdcom.com ([210.4.77.142]:39899 "EHLO smtp.bdcom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760911Ab0FRLkn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jun 2010 07:40:43 -0400
Received: from [192.168.1.3] (unknown [10.0.20.203])
	by smtp.bdcom.net (Postfix) with ESMTP id 8CE84288DE6
	for <linux-nfs@vger.kernel.org>; Fri, 18 Jun 2010 18:28:57 +0600 (BDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
I don't know if this forum is the right place for asking this question.
Please bear with me:
I have NFS4 server 'x' in Debian lenny
Three clients, a, b, and c: all Ubuntu 9.04
'a' has locked the files for last two months and it doesn't release the
lock. Whenever I try to open the file for read write in 'b' or 'c' I get
the message: 
"Document file is locked for editing by a(20.05.10 19:50)
Open document read-only or open a copy of document for editing."
I can open the file for read write in 'x' and 'a' only.

I tried with shutting down all the computers, changing the access time
of the file with touch, but without release of the file. What I had done
is switched from NFS3 to NFS4.

Can any one please help me or guide me to the right place for help.

Thanks

aikhan

