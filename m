Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41156 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796Ab0JMVUP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 17:20:15 -0400
Subject: Re: [PATCH 5/5] NFS: clear fsinfo before sendign rpc
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <4CB62105.2040908@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
	 <1285758613-26897-1-git-send-email-bhalevy@panasas.com>
	 <AANLkTim8BCOgLNXZt3QKLX=g1dEruNEWHsb2GPs2AVYD@mail.gmail.com>
	 <4CB617ED.4000504@panasas.com>
	 <1287003279.3015.205.camel@heimdal.trondhjem.org>
	 <4CB62105.2040908@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 13 Oct 2010 17:20:13 -0400
Message-ID: <1287004813.3015.212.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-10-13 at 17:13 -0400, Benny Halevy wrote:
> On 2010-10-13 16:54, Trond Myklebust wrote:
> > On Wed, 2010-10-13 at 16:34 -0400, Benny Halevy wrote:
> >> On 2010-10-13 14:03, Fred Isaman wrote:
> >>> On Wed, Sep 29, 2010 at 7:10 AM, Benny Halevy <bhalevy@panasas.com> wrote:
> >>>> To initialize all values to zero, in case the server or protocol version
> >>>> do no support particular attributes.
> >>>
> >>> Sorry for the delayed response, but...
> >>>
> >>> Zero is not an appropriate default for many of the values.  Further,
> >>> decode_fsinfo sets a default for each value, even in cases where the
> >>> server or protocol version do not support particular attributes.  So
> >>> this patch seems to server no purpose.
> >>
> >> Note that nfs_probe_fsinfo is called also for nfs version 2 and 3
> >> and these don't know anything about nfsv4.1 attributes so they can't
> >> cannot explicitly set them to any default value.
> > 
> > Err... Why would we care? Under exactly what circumstances would we want
> > generic code to be processing fsinfo attributes that are specific only
> > to NFSv4.1?
> > 
> > Trond
> 
> Originally, set_pnfs_layoutdriver, was called only for nfsv4.1
> but we changed it to always be called in nfs_server_set_fsinfo()

So it relies on a flag in the fsinfo structure to tell it that this is a
pNFS-capable server? That's fine, but in that case, you should perhaps
explicitly initialise that flag to the non-pNFS capable value in the
generic code.
We shouldn't need to zero out the entire structure.

Cheers
  Trond
