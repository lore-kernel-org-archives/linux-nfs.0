From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Bug 14276] nfsroot will not remount rw and claims illegal
 options
Date: Sun, 04 Oct 2009 15:06:02 -0400
Message-ID: <1254683162.9064.2.camel@heimdal.trondhjem.org>
References: <bug-14276-104@http.bugzilla.kernel.org/>
	 <200910041748.n94HmwPY005082@demeter.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org,
	"Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
	Hans de Bruin <bruinjm-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>
To: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56956 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757644AbZJDTGn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Oct 2009 15:06:43 -0400
In-Reply-To: <200910041748.n94HmwPY005082-jEpIWWs/U2wOASNP4CLbKB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-10-04 at 17:48 +0000, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=14276
> 
> 
> 
> 
> 
> --- Comment #6 from Hans de Bruin <bruinjm-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>  2009-10-04 17:48:57 ---
> hans@orion:/var/diskless/kernel/linux-2.6$ git bisect bad
> 53a0b9c4c99ab0085a06421f71592722e5b3fd5f is first bad commit
> commit 53a0b9c4c99ab0085a06421f71592722e5b3fd5f
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Sun Aug 9 15:09:36 2009 -0400
> 
>     NFS: Replace nfs_parse_ip_address() with rpc_pton()
> 
>     Clean up: Use the common routine now provided in sunrpc.ko for parsing
> mount
>     addresses.
> 
>     Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> :040000 040000 31c3998309b2c325b7ea927498e1a7e78e0e7747
> 513edbc936111eda9d1646db17e7240c77a32c42 M      fs
> hans@orion:/var/diskless/kernel/linux-2.6$

OK. Switching over to email.

Chuck, can you see how the rpc_pton() might be breaking nfsroot?
The cmdline is of the form

    root=/dev/nfs nfsroot=10.10.0.2:/nfs/gemini,v3,tcp ro ip=::::::dhcp

Cheers
  Trond


