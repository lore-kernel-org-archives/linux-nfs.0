Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:57829 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750813Ab2HCB57 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 21:57:59 -0400
Received: from sc9-mailhost2.vmware.com (sc9-mailhost2.vmware.com [10.113.161.72])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 1332B285C8
	for <linux-nfs@vger.kernel.org>; Thu,  2 Aug 2012 18:57:59 -0700 (PDT)
Received: from zimbra-prod-mta-3.vmware.com (zimbra-prod-mta-3.vmware.com [10.113.160.227])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id 0FC13B02F3
	for <linux-nfs@vger.kernel.org>; Thu,  2 Aug 2012 18:57:59 -0700 (PDT)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zimbra-prod-mta-3.vmware.com (Postfix) with ESMTP id 0C704E2A9F
	for <linux-nfs@vger.kernel.org>; Thu,  2 Aug 2012 18:57:59 -0700 (PDT)
Received: from zimbra-prod-mta-3.vmware.com ([127.0.0.1])
	by localhost (zimbra-prod-mta-3.vmware.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id y4PJsxqcYuqj for <linux-nfs@vger.kernel.org>;
	Thu,  2 Aug 2012 18:57:58 -0700 (PDT)
Received: from zimbra-prod-mbox-9.vmware.com (zimbra-prod-mbox-9.vmware.com [10.113.161.191])
	by zimbra-prod-mta-3.vmware.com (Postfix) with ESMTP id EE362E00C5
	for <linux-nfs@vger.kernel.org>; Thu,  2 Aug 2012 18:57:58 -0700 (PDT)
Date: Thu, 2 Aug 2012 18:57:58 -0700 (PDT)
From: Ed Goggin <egoggin@vmware.com>
To: linux-nfs@vger.kernel.org
Message-ID: <1781697815.4540720.1343959078882.JavaMail.root@vmware.com>
Subject: stale or not stale
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


It seems that nfsd can return reply attributes with a link count of zero but without an NFS3ERR_STALE status.  We've seen this actually happen for a write request to a file with a single link that  is concurrently being removed without NLM lock protection.  What is the proper behavior here?
