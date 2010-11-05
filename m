From: "Dr. Md. Aminul Islam Khan" <aikhan_lab-jH00EaABlX1eoWH0uzbU5w@public.gmane.org>
Subject: Unable to unlock nfs4 mounted file
Date: Fri, 05 Nov 2010 19:06:25 +0600
Message-ID: <1288962385.3936.6.camel@aikhan-laptop>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.bdcom.net ([210.4.77.142]:60676 "EHLO smtp.bdcom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754246Ab0KENQd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Nov 2010 09:16:33 -0400
Received: from [192.168.1.3] (unknown [10.0.20.203])
	by smtp.bdcom.net (Postfix) with ESMTP id 9EE96286C65
	for <linux-nfs@vger.kernel.org>; Fri,  5 Nov 2010 19:05:40 +0600 (BDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
My nfs server is on Debian lenny.
Using nfs clients a, b and c on Ubuntu 9.04
Client a opened nfs4 served file "xxx.odt" and closed it.
Client a tries to open the file, message is:
Document file 'xxx.odt' is locked for editing by:
khan (16.04.2010 21:08)
Open document read-only or open a copy of the document for editing.

Help in unlocking the file is highly appreciated


Regards

aikhan

