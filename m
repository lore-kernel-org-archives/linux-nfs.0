From: Henrik Grindal Bakken <hgb-6miFZF/5cTBuMpJDpNschA@public.gmane.org>
Subject: Re: NFS problem after upgrade from 2.6.32 to 2.6.3[3-7]
Date: Fri, 19 Nov 2010 15:24:07 +0100
Message-ID: <m3fwux2xyw.fsf@prentice.rd.tandberg.com>
References: <x2e1v6i7wk2.fsf@anakin.ifi.uio.no>
	<6B116440-2E1A-4E2A-9D56-EF30DAE5BD7E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rtp-iport-1.cisco.com ([64.102.122.148]:59051 "EHLO
	rtp-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918Ab0KSOYL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Nov 2010 09:24:11 -0500
In-Reply-To: <6B116440-2E1A-4E2A-9D56-EF30DAE5BD7E@oracle.com> (Chuck Lever's
	message of "Thu, 18 Nov 2010 10:20:48 -0500")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> writes:

> On Nov 18, 2010, at 5:31 AM, Henrik Grindal Bakken wrote:
>
>> I've tried to google the error message, to no avail.  The only hits I
>> get are from commit messages.
>
> One thing to note: the kernel uses TCP when performing rpcbind
> registration upcalls.  You might try adding back the TCP entries in
> /etc/netconfig to cause rpcbind to create TCP listeners.

That solved it!  Thanks.  I was convinced I had tried that, but
apparently I hadn't.


-- 
Henrik Grindal Bakken <hgb-6miFZF/5cTBuMpJDpNschA@public.gmane.org>
PGP ID: 8D436E52
Fingerprint: 131D 9590 F0CF 47EF 7963  02AF 9236 D25A 8D43 6E52
