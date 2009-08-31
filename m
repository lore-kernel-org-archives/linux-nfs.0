From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux client mount fails with Gluster NFSv3 server
Date: Mon, 31 Aug 2009 13:12:51 -0400
Message-ID: <1251738771.5144.21.camel@heimdal.trondhjem.org>
References: <4A9BD90B.4090804@gluster.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:50577 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbZHaVtf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2009 17:49:35 -0400
Received: from mail-mx4.uio.no ([129.240.10.45])
	by mail-out2.uio.no with esmtp (Exim 4.69)
	(envelope-from <trond.myklebust@fys.uio.no>)
	id 1MiEkr-0002jT-6C
	for linux-nfs@vger.kernel.org; Mon, 31 Aug 2009 23:49:37 +0200
Received: from mail-jess.uio.no ([129.240.7.9])
	by mail-mx4.uio.no with esmtp  (Exim 4.69)
	(envelope-from <trond.myklebust@fys.uio.no>)
	id 1MiEkr-0003Bc-4r
	for linux-nfs@vger.kernel.org; Mon, 31 Aug 2009 23:49:37 +0200
Received: from root by mail-jess.uio.no with local-bsmtp (Exim 4.44)
	id 1MiEkr-0007Gh-3y
	for linux-nfs@vger.kernel.org; Mon, 31 Aug 2009 23:49:37 +0200
In-Reply-To: <4A9BD90B.4090804-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-31 at 19:37 +0530, Shehjar Tikoo wrote:
> Hi All
> 
> I am writing a NFSv3 server as part of the Gluster clustered FS.
> To start with, I've implemented the Mountv3 protocol and am just
> starting out with NFSv3. In NFSv3, the first thing I've implemented
> is the FSINFO and GETATTR calls to support mounting with NFS client.
> 
> The problem I am facing is this. The Linux NFS client fails to mount
> the remote export even though it is successfully receiving the file
> handle from the MNT request and the result of the FSINFO call. This
> is shown in the attached pcap file, which would be best viewed through
> wireshark with "rpc" as the display filter.
> 
> The command line output is shown below:
> 
> root@indus:statcache# mount 127.0.0.1:/pos1 /mnt -o noacl,nolock
> mount.nfs: mounting 127.0.0.1:/pos1 failed, reason given by server:
>    No such file or directory
> 
> This happens even though, we're told the following by showmount.
> root@indus:statcache# showmount -e
> Export list for indus:
> /pos1 (everyone)
> /pos2 (everyone)
> /pos3 (everyone)
> /pos4 (everyone)
> root@indus:statcache#
> 
> ..where /pos1, /pos2, etc are exports from the locally running Gluster
> NFS server.
> 
> As you'll notice in the trace, there is no NFSv3 request after
> the FSINFO, so I've a feeling it could be that some field in the
> FSINFO reply is not what the Linux NFS client is expecting. Could that
> be the reason for the mount failure?
> 
> What else should I be looking into to investigate this further?
> 
> The client is a 2.6.18-5 kernel supplied with Debian on an AMD64 box.
> nfs-utils is version 1.1.4.
> 
> Many thanks,
> -Shehjar

Wireshark fails to decode your server's reply too. I'd start looking
there...

Cheers
  Trond

