Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:45665 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405Ab2GBOJs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2012 10:09:48 -0400
Subject: Re: Linux NFSv4 client uses returned delegation in subsequent READ resulting in hang (BAD_STATEID)
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAPD_G3L0wwzCWyoPJp_sKpuQ0J7+avn-ejEn-WnXf81zr=-LqA@mail.gmail.com>
Date: Mon, 2 Jul 2012 10:09:50 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <2E097766-1FA2-42E1-B790-B3BBC254B705@oracle.com>
References: <CAPD_G3L0wwzCWyoPJp_sKpuQ0J7+avn-ejEn-WnXf81zr=-LqA@mail.gmail.com>
To: "Charles 'Boyo" <charlesboyo@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 30, 2012, at 9:53 PM, Charles 'Boyo wrote:

> Hello.
> 
> I have repeatedly had Linux NFS clients hang while trying to access
> files on a NFSv4 mount (Solaris).
> Investigations revealed that this client is using a delegation that it
> has already returned, resulting in the BAD_STATEID error.
> Unfortunately, it then proceeds to hammer the server with these
> "doomed" requests, resulting in the client-side unresponsiveness and
> constant network traffic.
> 
> A sample trace can be found at http://pastebin.centos.org/39046
> As shown, the READ in frame 10 (line 112) follows the DELEGRETURN in
> frame 9 which results in the error. This READ was then repeated
> infinitely until either the server or client was restarted.
> Disabling delegations on the server-side caused the problem to cease.
> So what is wrong with delegations on the client-side?

Usually we see this behavior because of a race between an OPEN with delegation and a delegation recall.  In this case, however, the client is actively returning a READ delegation, then proceeding to use it anyway.  I don't see the server's recall callback, though, and there are other indications that this trace is not complete.  So it's hard to be 100% confident.

As far as I know, the EL6.2 client does not have support for recovering a single bad STATEID, which is why it is looping.  That support is available in mainline kernels 3.0 and later.

However, it seems to me that it is a bug for the client to continue using a delegation that it has returned.

You have already found one work-around: disable delegations on the NFS server.  Or you could mount with NFSv3.  Or, if feasible, your application could be modified to use fcntl() locking.


> I am using the latest nfs-utils packages and my mount options are as
> shown below:
> 
> # cat /etc/redhat-release
> CentOS release 6.2 (Final)
> 
> # uname -r
> 2.6.32-220.4.1.el6.x86_64
> 
> # rpm -qa '*nfs*'
> nfs-utils-lib-1.1.5-4.el6.x86_64
> nfs-utils-1.2.3-15.el6_2.1.x86_64
> 
> # grep nfs4 /proc/mounts
> 10.51.1.6:/SharedFolder/ /var/LocalMountPoint nfs4
> rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.51.1.34,minorversion=0,local_lock=none,addr=10.51.1.6
> 0 0
> 
> Regards,
> 
> Charles
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

