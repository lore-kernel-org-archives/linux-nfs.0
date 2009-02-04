From: Alan Tam <alan.tam-SFtwRVCDW+zye9KiRLayRdBPR1lH4CV8@public.gmane.org>
Subject: nfs operational access logging
Date: Wed, 4 Feb 2009 16:53:03 +0800
Message-ID: <OF030A37B3.8E5C3B90-ON48257553.00297914-48257553.0030CDA9@meadvillegroup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.meadvillegroup.com ([210.177.116.229]:59836 "EHLO
	smtp.meadvillegroup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936AbZBDIxM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2009 03:53:12 -0500
Received: from mtgmail.meadvillegroup.com (unknown [172.30.254.201])
	by smtp.meadvillegroup.com (Postfix) with ESMTP id 49C3412C7CE
	for <linux-nfs@vger.kernel.org>; Wed,  4 Feb 2009 16:53:16 +0800 (HKT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear,

Any plan to have the operational file access logging in the linux nfs 
server? Solaris has the logging daemon nfslogd, but seems Linux doesn't 
have the equivalent.

I have difficulties in having any audit logging on the nfs service.

Best regards,

Alan
