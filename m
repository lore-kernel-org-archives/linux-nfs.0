Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:50400 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888Ab3BRFK6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 00:10:58 -0500
Message-ID: <5121B7BA.7020509@parallels.com>
Date: Mon, 18 Feb 2013 09:10:18 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>,
        <linux-kernel@vger.kernel.org>, <devel@openvz.org>
Subject: Re: [PATCH v2 0/4] nfsd: make is works in a container
References: <20130201125210.3257.46454.stgit@localhost.localdomain> <20130215162021.GK8343@fieldses.org>
In-Reply-To: <20130215162021.GK8343@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

15.02.2013 20:20, J. Bruce Fields пишет:
> On Fri, Feb 01, 2013 at 03:56:05PM +0300, Stanislav Kinsbursky wrote:
>> This patch set finally enables NFSd in container.
>> I've tested it in container with it's own root, and also pid, net and mount
>> namespaces.
>
> Thanks, these look fine to me; applying.  They should show up in my
> for-3.9 branch sometime today.
>

Thanks!


-- 
Best regards,
Stanislav Kinsbursky
