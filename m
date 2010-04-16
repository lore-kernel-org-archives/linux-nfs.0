From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: Adds support for more encryption types.
Date: Fri, 16 Apr 2010 13:53:38 -0400
Message-ID: <4BC8A422.60603@RedHat.com>
References: <1271272729-24422-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40999 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598Ab0DPRxj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 13:53:39 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o3GHrdPo012584
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:53:39 -0400
Received: from badhat.bos.devel.redhat.com (vpn-237-52.phx2.redhat.com [10.3.237.52])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o3GHrcd0012029
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:53:38 -0400
In-Reply-To: <1271272729-24422-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/14/2010 03:18 PM, steved@redhat.com wrote:
> From: Steve Dickson <steved@redhat.com>
> 
> These three gssd patches added support for more DES and non-DES
> encryption types. They were authored by Kevin Coffman and tested
> by me on several recent kernels. 
> 
> Kevin Coffman (3):
>   gssd: move function limit_krb5_enctypes into the exported functions area
>   Try to use kernel function to determine supported Kerberos enctypes.
>   Add support for non-DES encryption types.
Committed and pushed...

steved.
