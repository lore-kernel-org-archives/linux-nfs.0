Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51383 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751863AbbDARyh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2015 13:54:37 -0400
Date: Wed, 1 Apr 2015 13:54:37 -0400
To: lyndat3@your-mail.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: file xfer over NFSv4 with 'sync' ~300X slower than with 'async' ?
Message-ID: <20150401175437.GD3040@fieldses.org>
References: <1427751843.1013981.247256753.2BA43388@webmail.messagingengine.com>
 <1427811676.1314276.247565589.4E14003B@webmail.messagingengine.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427811676.1314276.247565589.4E14003B@webmail.messagingengine.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2015 at 07:21:16AM -0700, lyndat3@your-mail.com wrote:
> Narrowing doen the issue, NFSv4 file xfer with 'sync' appears, here, to be ~ 300X slower than with 'async'.
> 
> (1) for NFSv4 mount with 'sync'
> 
> 	grep NAS1 /etc/auto.nfs4 
> 		NAS1   -fstype=nfs4,_netdev,rw,proto=tcp,sync,...  xen01.loc:/
> 
> a 100MB file xfer takes ~8 minutes
> 
> 	rm -f /mnt/NFS4/NAS1/file.out && \
> 	 time dd if=/dev/zero of=/mnt/NFS4/NAS1/file.out  bs=32K count=3K
> 		3072+0 records in
> 		3072+0 records out
> 		100663296 bytes (101 MB) copied, 485.721 s, 207 kB/s
> 
> 		real    8m5.861s
> 		user    0m0.012s
> 		sys     0m0.250s
> 
> (2) Change mount 'sync' -> 'async',
> 
> 	vi /etc/auto.nfs4 
> 	-	NAS1   -fstype=nfs4,_netdev,rw,proto=tcp,sync,...  xen01.loc:/
> 	+	NAS1   -fstype=nfs4,_netdev,rw,proto=tcp,async,...  xen01.loc:/
> 	systemctl restart autofs
> 
> the same 100MB file xfer takes ~ 2 seconds
> 
> 	rm -f /mnt/NFS4/NAS1/file.out && \
> 	 time dd if=/dev/zero of=/mnt/NFS4/NAS1/file.out  bs=32K count=3K
> 		3072+0 records in
> 		3072+0 records out
> 		100663296 bytes (101 MB) copied, 1.65577 s, 60.8 MB/s
> 
> 		real    0m1.658s
> 		user    0m0.000s
> 		sys     0m0.089s
> 
> 
> I'd expect 'sync' to be slower than 'async', but 300X ?

There's no maximum sync/async ratio.  You could make that ratio lower or
higher by varying dd's block size, for example.

The way I'd look at it, your dd of a 100MB file above is doing 3072
writes, and taking about 8*60/3072 =~ .16 seconds per write.

That does sound high.  Things to look at to understand why might include
the round-trip ping time to the server, and the time for the server's
disk to do a synchronous write.

--b.

> 
> Is there additional config that cures, or at least drastically improves, this slow down?
> 
> Some very old (10+ years) posts suggested kernel bugs, but those were fixed ages ago.  Maybe reemerged?
> 
> LT
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
