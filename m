From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: FLushing cached writes in nfs_getattr() and stat() delay
Date: Thu, 6 Nov 2008 14:55:21 -0500
Message-ID: <200811061455.21831.alexandre.sidorenko@hp.com>
References: <200811061034.06486.asid@hp.com> <200811061422.58920.alexandre.sidorenko@hp.com> <B01C5173-08DF-4EF9-8186-BEBDA8EE9862@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:45830 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbYKFTzm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2008 14:55:42 -0500
In-Reply-To: <B01C5173-08DF-4EF9-8186-BEBDA8EE9862@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On November 6, 2008 02:45:34 pm Chuck Lever wrote:
> There's a difference between an asynchronous RPC request, and an
> asynchronous write request.
>
> An async RPC means the process doesn't wait for the request to finish=
,
> it can perform other housekeeping.
>
> An async write means that the client delays sending NFS writes,
> maintaining the dirty data in its memory. =A0It can send the NFS writ=
e
> requests by means of an async RPC if it wishes. =A0A synchronous writ=
e
> means that the client will block the application until the server has
> replied that the dirty data is on the server's disk.

Thank you for clarification. I knew what RPC-async means but for some r=
eason=20
forgot what SYNC-write means, sorry for confusion. And yes, I should ha=
ve=20
looked at /proc/mounts instead of /etc/mtab

Regards,
Alex

--=20
------------------------------------------------------------------
Alexandre Sidorenko             email: asid@hp.com
Global Solutions Engineering:   Unix Networking
Hewlett-Packard (Canada)
------------------------------------------------------------------
