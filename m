From: Jon Forrest <jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org>
Subject: Re: To Automount or to Not Automount?
Date: Thu, 14 Jan 2010 13:15:17 -0800
Message-ID: <4B4F8965.8020705@berkeley.edu>
References: <hint4t$gjt$1@ger.gmane.org> <4B4F8575.1010505@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Thomas Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cm02fe.IST.Berkeley.EDU ([169.229.218.143]:37881 "EHLO
	cm02fe.IST.Berkeley.EDU" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab0ANVen (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 16:34:43 -0500
In-Reply-To: <4B4F8575.1010505-xsfywfwIY+M@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/14/2010 12:58 PM, Thomas Haynes wrote:

> Is every node mounting every other node?

No. The compute nodes mount from the
one file server. The compute nodes
don't export anything.

> Or are you talking about every node mounting a central
> server?

Yes.

One person whom I respect told me that static mounts
result in more overhead on the server. I didn't
understand this but I don't claim to be
an NFS expert.


-- 
Jon Forrest
Research Computing Support
College of Chemistry
173 Tan Hall
University of California Berkeley
Berkeley, CA
94720-1460
510-643-1032
jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org
