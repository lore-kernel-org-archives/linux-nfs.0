Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35056 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753975Ab1AYW2y convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jan 2011 17:28:54 -0500
Subject: Re: Stale file not being refreshed automatically?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nathan March <nathan@gt.net>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4D3F4A8A.7040003@gt.net>
References: <4D3F4A8A.7040003@gt.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 Jan 2011 17:28:52 -0500
Message-ID: <1295994532.6867.12.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-25 at 14:11 -0800, Nathan March wrote: 
> Hi All,
> 
> Having a strange issue, I've reproduced this both on nfs 3 and 4. 
> Currently using v4 with:
> 
> exports:
> /var/home/voyage 
> 10.2.1.0/24(rw,fsid=0,async,wdelay,secure,no_subtree_check,anonuid=1000,anongid=1006)
> 
> fstab:
> 10.2.1.1:/ /mnt/voyage nfs4 
> rsize=32768,wsize=32768,noatime,nosuid,rw,bg,hard,intr 0 0
> 
> Can be produced using these two commands on 2 machines:
> 
> perl -le '$| = 1 ; while (1) { sleep 1; $res = -e "/home/voyage/test"; 
> if ($res) { print "-e : $res"; } else { print "-e : $res ($!)"; } }'
> -e : 1
> 
> perl -le '$| = 1 ; while (1) { sleep 5; open(F, ">", 
> "/home/voyage/test.foo"); close F; my $res = 
> rename("/home/voyage/test.foo", "/home/voyage/test"); print "rename 
> ($res)"; }'
> 
> The first command will occasionally print out: -e :  (Stale NFS file handle)
> 
> Now according to http://nfs.sourceforge.net/#faq_a10 as of 2.6.12 the 
> vfs should automatically retry when it gets a estale during path 
> resolution. This doesn't appear to be happening though based on the 
> errors I'm seeing.
> 
> Anyone have any thoughts on what might be happening here? Or am I 
> misinterpreting that faq entry? (This is on ext3 if it matters)

Does '-e' in perl only do a lookup, or does it result in a 'stat()'
call? If the latter, then your test is flawed: a stat() is a lookup+a
getattr, and the latter can definitely return ESTALE when you are
constantly replacing the file.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

