Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33716 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbcGFN0k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 09:26:40 -0400
Received: by mail-qk0-f173.google.com with SMTP id e3so112844773qkd.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 06:26:39 -0700 (PDT)
Message-ID: <1467811595.3622.2.camel@redhat.com>
Subject: Re: When can nfsv3 returns nfs3err_jukebox to client?
From: Jeff Layton <jlayton@redhat.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Pankaj Singh <psingh.ait@gmail.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 06 Jul 2016 09:26:35 -0400
In-Reply-To: <1841001989.22448255.1467799567282.JavaMail.zimbra@desy.de>
References: <CAPrqf91tFmR3BVk8RbBbXvMsFa-SOC2WKqGvsb-LvTiLUT61hA@mail.gmail.com>
	 <1841001989.22448255.1467799567282.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-07-06 at 12:06 +0200, Mkrtchyan, Tigran wrote:
> Hi,
> 
> ----- Original Message -----
> > 
> > From: "Pankaj Singh" <psingh.ait@gmail.com>
> > To: linux-nfs@vger.kernel.org
> > Sent: Wednesday, July 6, 2016 7:52:45 AM
> > Subject: When can nfsv3 returns nfs3err_jukebox to client?
> > 
> > Hi All,
> > 
> > I have read in the RFC 1813 that "nfs3err_jukebox" will be return only
> > when server is not able to finish the RPC request within time. To
> > indicate client to wait and retry again.
> > 
> > Could anyone tell me is there any senario where NFSv3 or SUN RPC can
> > send this error to client, if not returned from base filesystem?
> > 
> If a migrating file system exported through NFS, then server may return
> err_jukebox/delay to the client on an IO request while mounting the offline
> volume or tape to make it accessible.
> 
> Tigran.
> 

I think that was the original intent, but many servers will return that
whenever there is a problem that is perceived as temporary. For
instance, knfsd will often return that when it hits a problem
allocating memory while processing an RPC.

-- 
Jeff Layton <jlayton@redhat.com>

