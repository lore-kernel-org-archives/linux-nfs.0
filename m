Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54943 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933694Ab2JXUCu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 16:02:50 -0400
Date: Wed, 24 Oct 2012 16:02:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
Message-ID: <20121024200249.GC6697@fieldses.org>
References: <20121016125832.GC30649@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121016125832.GC30649@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anyone get a chance to look at this?  It seems very reproduceable.

--b.

On Tue, Oct 16, 2012 at 08:58:32AM -0400, bfields wrote:
> On 3.7-rc1:
> 
> 	client# mount -tnfs -osec=krb5,vers=3 server:/exports/ext4 /mnt/
> 
> 		server# ls -l /exports/ext4|grep TMP
> 		server#
> 
> 	# mkdir /mnt/TMP
> 	mkdir: cannot create directory `/mnt/TMP': Permission denied
> 
> 		server# ls -l /exports/ext4|grep TMP
> 		drwxr-xr-x  2 nfsnobody nfsnobody 4096 Oct 16 08:56 TMP
> 		server#
> 
> Wireshark also shows that the create succeeds.
> 
> --b.
