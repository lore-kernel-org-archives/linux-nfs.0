From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 17:48:59 -0400
Message-ID: <1248212939.5034.1.camel@heimdal.trondhjem.org>
References: <4A64EB1F.4000602@candelatech.com>
	 <1248178527.5222.0.camel@heimdal.trondhjem.org>
	 <4A65F184.5060802@candelatech.com>
	 <1248196339.21343.8.camel@heimdal.trondhjem.org>
	 <4A65FCB2.6080903@candelatech.com>
	 <1248199140.21343.17.camel@heimdal.trondhjem.org>
	 <4A660295.9020807@candelatech.com>
	 <1248200897.21343.19.camel@heimdal.trondhjem.org>
	 <4A6609A9.3000504@candelatech.com>
	 <1248211050.21343.38.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:41490 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503AbZGUVtE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2009 17:49:04 -0400
In-Reply-To: <1248211050.21343.38.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-07-21 at 17:17 -0400, Trond Myklebust wrote:
> On Tue, 2009-07-21 at 11:32 -0700, Ben Greear wrote:
> > On 07/21/2009 11:28 AM, Trond Myklebust wrote:
> > > On Tue, 2009-07-21 at 11:01 -0700, Ben Greear wrote:
> > >> On 07/21/2009 10:59 AM, Trond Myklebust wrote:
> > >>> On Tue, 2009-07-21 at 10:36 -0700, Ben Greear wrote:
> > >>>> On 07/21/2009 10:12 AM, Trond Myklebust wrote:
> > >>>>> On Tue, 2009-07-21 at 09:49 -0700, Ben Greear wrote:
> > >>>>>> On 07/21/2009 05:15 AM, Trond Myklebust wrote:
> > >>>>>>
> > >>>>>>> What does /var/lib/nfs/v4recovery look like on the server?
> > >>>>>> The server was misconfigured, but I still think the client should
> > >>>>>> behave better in this case.  If you cannot reproduce it, let me know
> > >>>>>> and I can try to be more specific.  If you still want the v4recovery
> > >>>>>> information, let me know and I'll send it.
> > >>>>> So how should the client behave, when a screwed up server allows it to
> > >>>>> mount but starts returning illegal values for setclientid? The only
> > >>>>> thing I can see we could do is to tell the user EINSANESERVER...
> > >>>> Well, it could just fail the mount and give up and not overly spam
> > >>>> /var/log/messages in a tight loop perhaps?
> > >>> This doesn't happen at mount time. It happens when you open a file.
> > >> Not for me, and evidently not for the other person that reported
> > >> similar results.  All I had to do was attempt the mount (which never
> > >> completed).
> > >>
> > >> Thanks,
> > >> Ben
> > >
> > > Ah... You have NFS_V4_1 enabled despite the Kconfig warning... Does the
> > > bug occur when you turn this off too?
> > 
> > Yes, it did.
> 
> OK. The following patch should fix that particular regression.
> 
> Note that there is a bug remaining inside nfs4_init_session(): we
> shouldn't be copying the rsize/wsize into the nfs_client if the latter
> was already initialised. I'm going to leave that for the moment, though,
> since that bug wasn't introduced by my patch, and it doesn't affect
> NFSv4.0.

With that patch applied, I now get the expected behaviour when mounting
a server with no NFSv4 root from a 2.6.31-rc3 based client:

root@heimdal:~# mount -t nfs4 munkholm.local:/ /mnt
mount.nfs4: mounting munkholm.local:/ failed, reason given by server:
  No such file or directory

Trond

