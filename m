Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f170.google.com ([209.85.214.170]:42529 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbaBRROu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Feb 2014 12:14:50 -0500
Received: by mail-ob0-f170.google.com with SMTP id va2so18787314obc.15
        for <linux-nfs@vger.kernel.org>; Tue, 18 Feb 2014 09:14:49 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: multiple NFS4ERR_STALE_STATEID on 3.12 (wheezy)
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <87bny4758r.fsf@leto.enst.fr>
Date: Tue, 18 Feb 2014 12:14:46 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <053973FB-ED19-4193-965C-7ADA850B44F2@primarydata.com>
References: <87bny4758r.fsf@leto.enst.fr>
To: Manuel Sabban <manuel.sabban@telecom-paristech.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 18, 2014, at 11:30, Manuel Sabban <manuel.sabban@telecom-paristech.fr> wrote:

> Hi,
> 
> We have approximatively one hundred desktop computers with 3.12.6 kernel
> and debian wheezy system. NFS is used for homes. Mount options are
> "rw,nosuid,nodev,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,
> soft,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,local_lock=none".
> 
> The NFS server we use is the ZFS appliance from Oracle
> (http://www.oracle.com/us/products/servers-storage/storage/nas/zfs7420/overview/index.html). The
> server does some short-to-very-long pauses (from several minutes to
> several hours, because of a known bug acknowledged by oracle in our
> configuration) and we suspect that this behaviour trigger the behaviour
> described below.
> 
> What we understand is that when the server is back online, the client
> try to write something on the NFS and the server throw a STALE_STATEID
> error. And, then the client try again, with the same result, and try
> again, and again... This is happening at the rate of 3300 packets per
> second, on the example below.
> 
> At this point, the client get hung, and the enabled traces
> showed a full trace file of
> kworker/1:0-11993 [001] .... 1171115.807948: nfs4_read: error=-10023 (STALE_STATEID) fileid=00:1f:283 fhandle=0xb1863420 offset=0 count=12288
> kworker/1:0-11993 [001] .... 1171115.808543: nfs4_read: error=-10023 (STALE_STATEID) fileid=00:1f:283 fhandle=0xb1863420 offset=0 count=12288
> kworker/1:0-11993 [001] .... 1171115.809111: nfs4_read: error=-10023 (STALE_STATEID) fileid=00:1f:283 fhandle=0xb1863420 offset=0 count=12288
> 
> The network dump showed similar things with the NFS4ERR_STALE_STATEID
> error. Then, the computer has to be hard rebooted.
> 
> How can this behaviour be avoided ?
> 
> You will find debugging traces and network dump at
> http://perso.telecom-paristech.fr/~sabban/debugNFS/tsilinuxb96

So, the exact sequence in the wireshark dump is a successful RENEW followed by a READ with STALE_STATEID. I’m guessing that they still haven’t fixed the RENEW bug that we reported several years ago: if the lease has expired, then it should return NFS4ERR_STALE_CLIENTID, not NFS4_OK…

Yes, clients do rely on this behaviour...

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

