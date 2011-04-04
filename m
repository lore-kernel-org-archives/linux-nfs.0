Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27579 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754104Ab1DDNnl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Apr 2011 09:43:41 -0400
Message-ID: <4D99CAFC.5070402@netapp.com>
Date: Mon, 04 Apr 2011 09:43:24 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: secinfo_no_name question
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce,

I'm looking at secinfo_no_name on the client.  RFC 5661 says to says to send PUTROOTFH followed by SECINFO_NO_NAME in the same compound and to use SECINFO_STYLE4_CURRENT_FH.  My compound is: SEQUENCE, PUTROOTFH, SECINFO_NO_NAME.  The server processes up to the PUTROOTFH, and then returns with NFS4ERR_WRONGSEC.  

Am I doing something wrong?  Is this a server problem?

Thanks,
Bryan
