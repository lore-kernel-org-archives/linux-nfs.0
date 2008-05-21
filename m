From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 3/8] SUNRPC: Use RPC procedure name in call_verify
Date: Wed, 21 May 2008 08:38:38 -0400
Message-ID: <483417CE.1070308@redhat.com>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net> <20080520202941.3851.61861.stgit@ellison.1015granger.net> <1211318498.26809.13.camel@localhost> <DF95EE8C-4F20-4B4A-9967-9AD354196D4D@oracle.com> <48341218.10009@redhat.com> <RTPCLUEXC1-PRDQrwFN00000141@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42780 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764354AbYEUMi5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2008 08:38:57 -0400
In-Reply-To: <RTPCLUEXC1-PRDQrwFN00000141-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Talpey, Thomas wrote:
> At 08:14 AM 5/21/2008, Peter Staubach wrote:
>   
>> I have seen servers which didn't implement the NULL_PROC procedure
>> for protocols like NFS_ACL.  Beats me why.
>>     
>
> Names. We want names. :-)

:-)

Names withheld to prevent embarrassment of the guilty?

Actually, I don't remember anymore who they were, but I suspect
that I would have complained to them at the time.  It just isn't
that hard to implement a procedure which doesn't do anything but
respond to the client.

       ps
