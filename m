Return-Path: linux-nfs-owner@vger.kernel.org
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:54349 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888AbaDCU5M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Apr 2014 16:57:12 -0400
Message-ID: <533DC9CA.6030508@pobox.com>
Date: Thu, 03 Apr 2014 16:51:22 -0400
From: Mark Lord <mlord@pobox.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, Albert Fluegel <af@muc.de>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: linux-3.14 nfsd regression
References: <533D8D73.1090603@pobox.com> <20140403171643.GB28790@pad.redhat.com> <533D9F8A.6030001@pobox.com> <20140403201533.GB8343@fieldses.org>
In-Reply-To: <20140403201533.GB8343@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14-04-03 04:15 PM, J. Bruce Fields wrote:
> On Thu, Apr 03, 2014 at 01:51:06PM -0400, Mark Lord wrote:
>> On 14-04-03 01:16 PM, J. Bruce Fields wrote:
>>> The original behavior was in practice harmless and changing it broke
>>> something, so I think we should definitely just revert this patch.
>>
>> Yup.  Who?
> 
> I'll submit this soon.
..

Thanks, Bruce!

-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
