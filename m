From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Different rsize/wsize for different NFS server software
Date: Tue, 12 May 2009 10:09:05 -0400
Message-ID: <1242137345.21939.6.camel@heimdal.trondhjem.org>
References: <4A0959F9.1010107@zresearch.com>
	 <4A097DE9.6030709@zresearch.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Shehjar Tikoo <shehjart-iP+wyIN8Xge1Z/+hSey0Gg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:33998 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755085AbZELOJI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2009 10:09:08 -0400
In-Reply-To: <4A097DE9.6030709-iP+wyIN8Xge1Z/+hSey0Gg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-05-12 at 19:17 +0530, Shehjar Tikoo wrote:
> Shehjar Tikoo wrote:
> > Hi All
> > 
> > I've been running some tests using the linux NFS3 client using the
> > in-kernel NFS server and the unfs3 project.
> > 
> > I see that the client mounts the in-kernel server with default
> > [rw]size values of 32k and the unfs3 server using [rw]size values
> > of 512k. Where is this difference coming from, because I do not
> > specify these different [rw]size value on the command line for mount.
> > 
> 
> Through wireshark, I see that an FSINFO request is sent
> by the client in order to get the wtpref and rtpref values and that is
> what determines the wsize and rsize values at the client.
> 
> The next strange behaviour is that, with unfs3 as the server, I try
> to mount using wsize set to 65536 with the command:
> 
> $ mount  192.168.1.201:/server/ -o wsize=65536 /test/mount
> 
> but the /proc/mounts entry still reports a 512k wsize value.
> 
> $ cat /proc/mounts
> 192.168.1.201:/server/ /test/mount nfs 
> rw,vers=3,rsize=524288,wsize=524288,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=192.168.1.201 
> 0 0
> 
> and wireshark also shows client sending 512k requests.
> mount.fs version is: mount.nfs (linux nfs-utils 1.1.4)
> 
> Is there any way to force the client to use a 64k wsize value?

You probably have the exact same filesystem still mounted somewhere else
on that client. A 2.6.18 kernel will, in those circumstances, share the
same super block with both mount points, and will therefore not permit
you to use different mount options.

This is something which has been fixed in more recent kernels.

Trond

