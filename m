Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37883 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754850Ab1CQRiI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 13:38:08 -0400
Date: Thu, 17 Mar 2011 13:38:05 -0400
To: Adam Lackorzynski <adam@os.inf.tu-dresden.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: 2.6.38: Quota over NFS4
Message-ID: <20110317173805.GB30180@fieldses.org>
References: <20110317133247.GB6424@os.inf.tu-dresden.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110317133247.GB6424@os.inf.tu-dresden.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 17, 2011 at 02:32:47PM +0100, Adam Lackorzynski wrote:
> Hello,
> 
> I'm seeing a problem with quotas in a system where the server running
> 2.6.38 exports an XFS filesystem via NFS4 to a client. The client kernel
> version does not seem to play a role, checked with 2.6.38, 2.6.37 and
> 2.6.36. The following script and output show the problem:
> 
> #! /bin/sh
> 
> quota | grep home
> du
> cp /bin/ls x1
> du
> cat x1 > /dev/null
> rm x1
> du
> quota | grep home
> 
> Output:
> 
>    homes:/home/ 8194720  9072000 9174400          403670  500000  550000        
> 0       .
> 96      .
> 0       .
>    homes:/home/ 8194816  9072000 9174400          403671  500000  550000        
> 
> 
> As can be seen the 96 kb are still accounted on the quota of the user.
> Removing the 'cat' command from the script makes the quota be ok again
> (original value). Also mounting via nfs3 does not exhibit it, same for running
> the script on the nfs-server directly.

Does "df" show the same problem?  And does unmounting/remounting on the
client clear the problem?  (Or that, in combination with stopping the
server, unmounting the xfs export, remounting it, and restarting?)

Was there an earlier server version that didn't exhibit this problem?

--b.

> 
> Client mount options are:
> homes:/home/ /home nfs4 rw,nosuid,nodev,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=1.2.3.3,minorversion=0,local_lock=none,addr=1.2.3.4 0 0
> 
> Server mount options are:
> /dev/mapper/vg-homefs /home xfs rw,nosuid,nodev,relatime,attr2,usrquota 0 0
> 
> 
> 
> 
> Thanks,
> Adam
> -- 
> Adam                 adam@os.inf.tu-dresden.de
>   Lackorzynski         http://os.inf.tu-dresden.de/~adam/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
