Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36604 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdFBPBJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jun 2017 11:01:09 -0400
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v52F18x1007027
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Fri, 2 Jun 2017 15:01:08 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: Proposal for end-of-life for fedfs-utils development
Message-Id: <56804FBE-34B2-47FB-96EF-013D4476D89A@oracle.com>
Date: Fri, 2 Jun 2017 11:01:05 -0400
To: fedfs-utils developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Upstream fedfs-utils has not been under active development for
two years or more, and there is a scant user base. I'd like to
propose making 0.10 the final major release of fedfs-utils.

The plan:

- Since 0.10 is in at least one major enterprise distribution,
I will remain available to integrate security fixes and make
new minor releases in the 0.10 line, as needed, for one to
two more years.

- Retire and remove fedfs-utils from upstream mirror distros
such as Fedora rawhide.

- Transfer utilities such as nfsref into nfs-utils, with
support for FedFS junctions removed.

- Announcements of the change in status will be made on
fedfs-utils-announce and on the wiki.linux-nfs.org site.



Comments welcome!


--
Chuck Lever



