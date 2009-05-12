From: Shehjar Tikoo <shehjart-iP+wyIN8Xge1Z/+hSey0Gg@public.gmane.org>
Subject: Re: Different rsize/wsize for different NFS server software
Date: Tue, 12 May 2009 19:17:21 +0530
Message-ID: <4A097DE9.6030709@zresearch.com>
References: <4A0959F9.1010107@zresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [12.204.100.226] ([12.204.100.226]:43874 "EHLO gluster.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbZELNpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2009 09:45:05 -0400
Received: from [115.108.23.204] (helo=[192.168.1.90])
	by gluster.com with esmtpa (Exim 4.69)
	(envelope-from <shehjart-iP+wyIN8Xge1Z/+hSey0Gg@public.gmane.org>)
	id 1M3sHy-0004Um-SQ
	for linux-nfs@vger.kernel.org; Tue, 12 May 2009 06:44:59 -0700
In-Reply-To: <4A0959F9.1010107-iP+wyIN8Xge1Z/+hSey0Gg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Shehjar Tikoo wrote:
> Hi All
> 
> I've been running some tests using the linux NFS3 client using the
> in-kernel NFS server and the unfs3 project.
> 
> I see that the client mounts the in-kernel server with default
> [rw]size values of 32k and the unfs3 server using [rw]size values
> of 512k. Where is this difference coming from, because I do not
> specify these different [rw]size value on the command line for mount.
> 

Through wireshark, I see that an FSINFO request is sent
by the client in order to get the wtpref and rtpref values and that is
what determines the wsize and rsize values at the client.

The next strange behaviour is that, with unfs3 as the server, I try
to mount using wsize set to 65536 with the command:

$ mount  192.168.1.201:/server/ -o wsize=65536 /test/mount

but the /proc/mounts entry still reports a 512k wsize value.

$ cat /proc/mounts
192.168.1.201:/server/ /test/mount nfs 
rw,vers=3,rsize=524288,wsize=524288,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=192.168.1.201 
0 0

and wireshark also shows client sending 512k requests.
mount.fs version is: mount.nfs (linux nfs-utils 1.1.4)

Is there any way to force the client to use a 64k wsize value?

Thanks
Shehjar

> The client kernel is Debian's 2.6.18-5-amd64 and the server kernel
> is Fedora's 2.6.18-92.1.6.el5.
> 
> Thanks
> Shehjar
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

