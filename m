Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp07.online.nl ([194.134.42.52]:44088 "EHLO smtp07.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229Ab1FCSFg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jun 2011 14:05:36 -0400
Subject: Re: NFS3 + kerberos: performance issues
From: Vladimir Elisseev <vovan@vovan.nl>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1307104354.2477.17.camel@lade.trondhjem.org>
References: <1307086159.1052.19.camel@vovan.net.home>
	 <1307104354.2477.17.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 03 Jun 2011 19:57:16 +0200
Message-ID: <1307123836.1052.23.camel@vovan.net.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There's no mount command involved in timing. It's simply copy of the
same directory (with many small files to NFS share with and without
sec=krb5 mount option.

Vlad.

On Fri, 2011-06-03 at 08:32 -0400, Trond Myklebust wrote:
> On Fri, 2011-06-03 at 09:29 +0200, Vladimir Elisseev wrote: 
> > Hello,
> > 
> > After using nfs3 with kerberos for a while I discovered very poor
> > performance for some file operations like creation of files. There are
> > two observations:
> > - the overal nfs3 performance is good: for instance copying large files
> > works fine
> > - this poor performance is definitely related to kerberos as the same
> > volume exported without sec=krb5 works ~10 times faster with creating
> > files
> > I'd appreciate if somebody can explain this behaviour?
> > 
> > Below are some details about NFS server and client:
> > server:
> > - kernel 2.6.36
> > - export options rw,sec=krb5,no_root_squash,no_subtree_check
> > - nfs-utils 1.2.3
> > 
> > client:
> > - kernel 2.6.38 or 2.6.39 
> > - mout options (from /proc/mounts):
> > rw,nosuid,nodev,noatime,vers=3,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=krb5,mountaddr=192.168.1.219,mountvers=3,mountport=32767,mountproto=tcp,local_lock=none,addr=192.168.1.219
> > 
> > when the same volume exported without sec=krb5, the only option changes
> > in /proc/mounts is sec=sys
> 
> Can you please tell us a bit more about how you are measuring this? I
> might expect a x10 performance difference if the workload is dominated
> by the actual setting up of the RPCSEC_GSS session (i.e. you are timing
> mount+create one file or something like that). If we're talking about a
> workload where the RPCSEC_GSS negotiation can be neglected, however
> (mount+create 100000 files), I wouldn't expect any measurable
> performance impact from 'sec=krb'.
> 
> 

