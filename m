Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34924 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933255AbcDLRcm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Apr 2016 13:32:42 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 747C9C062C87
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2016 17:32:41 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u3CHWeO3031952
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2016 13:32:41 -0400
To: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Subject: rpcsecgss library support
Message-ID: <570D3138.3020309@RedHat.com>
Date: Tue, 12 Apr 2016 13:32:40 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Does anybody still use the rpcsecgssd library?

I know the upstream nfs-utils stopped using 
it when the gssproxy support was added. And
I know older distros like RHEL6 still use it. 

But I don't think the upstream library is 
even supported or used any more. So 
would like to rip the support out of
nfs-utils... 

any objections?

steved.
