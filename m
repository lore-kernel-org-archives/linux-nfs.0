From: Robert Gordon <Robert.Gordon-UdXhSnd/wVw@public.gmane.org>
Subject: Re: [PATCH 3/8] SUNRPC: Use RPC procedure name in call_verify
Date: Wed, 21 May 2008 10:27:51 -0500
Message-ID: <E3DF41A5-5DBA-42CE-ADE2-FAE8AC5E4722@Sun.COM>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net>
 <20080520202941.3851.61861.stgit@ellison.1015granger.net>
 <1211318498.26809.13.camel@localhost>
 <DF95EE8C-4F20-4B4A-9967-9AD354196D4D@oracle.com> <48341218.10009@redhat.com>
 <RTPCLUEXC1-PRDQrwFN00000141@RTPMVEXC1-PRD.hq.netapp.com>
 <483417CE.1070308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; delsp=yes; format=flowed; charset=US-ASCII
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brmea-mail-1.Sun.COM ([192.18.98.31]:44885 "EHLO
	brmea-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757389AbYEUPpO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 11:45:14 -0400
Received: from fe-amer-09.sun.com ([192.18.109.79])
	by brmea-mail-1.sun.com (8.13.6+Sun/8.12.9) with ESMTP id m4LFS5ZI014698
	for <linux-nfs@vger.kernel.org>; Wed, 21 May 2008 15:28:05 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K1800M0136NYQ00-suYR2Hc8r9/lQFUxb2hVpgC/G2K4zDHf@public.gmane.org>
 (original mail from Robert.Gordon-UdXhSnd/wVw@public.gmane.org) for linux-nfs@vger.kernel.org; Wed,
 21 May 2008 09:28:05 -0600 (MDT)
In-reply-to: <483417CE.1070308@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This being an accepted practice -- as opposed to a clearly
defined requirement in a spec someplace ??

On May 21, 2008, at 7:38 AM, Peter Staubach wrote:
> Talpey, Thomas wrote:
>> At 08:14 AM 5/21/2008, Peter Staubach wrote:
>>
>>> I have seen servers which didn't implement the NULL_PROC procedure
>>> for protocols like NFS_ACL.  Beats me why.
>>>
>>
>> Names. We want names. :-)
>
> :-)
>
> Names withheld to prevent embarrassment of the guilty?
>
> Actually, I don't remember anymore who they were, but I suspect
> that I would have complained to them at the time.  It just isn't
> that hard to implement a procedure which doesn't do anything but
> respond to the client.
>
>      ps
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

