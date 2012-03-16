Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:37076 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754463Ab2CPSOF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 14:14:05 -0400
Received: from sc9-mailhost2.vmware.com (sc9-mailhost2.vmware.com [10.113.161.72])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id 27C9728206
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 11:14:04 -0700 (PDT)
Received: from zimbra-prod-mta-3.vmware.com (zimbra-prod-mta-3.vmware.com [10.113.160.227])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id 22EE0B03FB
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 11:14:04 -0700 (PDT)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zimbra-prod-mta-3.vmware.com (Postfix) with ESMTP id 1D61B100712
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 11:14:04 -0700 (PDT)
Received: from zimbra-prod-mta-3.vmware.com ([127.0.0.1])
	by localhost (zimbra-prod-mta-3.vmware.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hOgrd3+dEgLD for <linux-nfs@vger.kernel.org>;
	Fri, 16 Mar 2012 11:14:04 -0700 (PDT)
Received: from zimbra-prod-mbox-3.vmware.com (zimbra-prod-mbox-3.vmware.com [10.113.160.203])
	by zimbra-prod-mta-3.vmware.com (Postfix) with ESMTP id 0A14E1006EC
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 11:14:04 -0700 (PDT)
From: "Alexandre Depoutovitch" <adepoutovitch@vmware.com>
To: <linux-nfs@vger.kernel.org>
References: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
In-Reply-To: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
Subject: About Direct I/O
Date: Fri, 16 Mar 2012 11:14:04 -0700 (PDT)
Message-ID: <6866525b.00001bd8.0000023d@aldep-VC.vmware.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,
I am trying to do random sector aligned writes to an NFS mounted disk. The
performance is order of magnitude worse than 4K (file system block size)
aligned I/O.
The reason is that NFS demon (Linux kernel 2.6.32) on the server side
always does buffered I/O, which behaves poorly for block unaligned
requests.
Is there a way to tell NFS daemon to use direct I/O? 
If not, is it an implementation limitation or there is a fundamental
problem with using direct I/O in NFS server?

Thank you,

Alex
