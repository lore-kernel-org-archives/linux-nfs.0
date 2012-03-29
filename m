Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:22694 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932608Ab2C2Pgs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 11:36:48 -0400
Message-ID: <4F748187.1070209@parallels.com>
Date: Thu, 29 Mar 2012 19:36:39 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 0/8] NFSd: precursor and cleanup patch set
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6> <20120329143218.GI16938@fieldses.org>
In-Reply-To: <20120329143218.GI16938@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

29.03.2012 18:32, J. Bruce Fields пишет:
> On Wed, Mar 28, 2012 at 07:08:53PM +0400, Stanislav Kinsbursky wrote:
>> This patch set prepares ground for making NFSd export and expkey caches
>> allocated and registered per network namespace context.
>> Mainly, it just replaces hard-coded pointers with dereferenced everywhere
>> required.
>
> Thanks.  I'll be travelling next week and may not get to look at this
> till I get back.
>

Yep, sure. No rush here...

-- 
Best regards,
Stanislav Kinsbursky
