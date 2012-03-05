Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e5.ny.us.ibm.com ([32.97.182.145]:33299 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755121Ab2CEEyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Mar 2012 23:54:12 -0500
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Sun, 4 Mar 2012 23:54:09 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6E93F6E8049
	for <linux-nfs@vger.kernel.org>; Sun,  4 Mar 2012 23:53:23 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q254rNTh273838
	for <linux-nfs@vger.kernel.org>; Sun, 4 Mar 2012 23:53:23 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q254rNmA014526
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 01:53:23 -0300
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q254rMWr014523
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 01:53:23 -0300
Date: Sun, 4 Mar 2012 22:53:22 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
Message-ID: <20120305045322.GB12833@us.ibm.com>
References: <20120302192758.GA28389@us.ibm.com>
 <4F513429.1050209@RedHat.com>
 <20120302220108.GA17119@us.ibm.com>
 <4F525741.2060404@RedHat.com>
 <1330801976.2781.19.camel@lade.trondhjem.org>
 <4F53ED3C.2020209@RedHat.com>
 <4F53F39E.9050802@RedHat.com>
 <1330903600.14357.10.camel@lade.trondhjem.org>
 <4F5402E4.4030506@RedHat.com>
 <1330913047.14357.19.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1330913047.14357.19.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond [Trond.Myklebust@netapp.com] wrote:
> On Sun, 2012-03-04 at 19:03 -0500, Steve Dickson wrote:
> > 
> > On 03/04/2012 06:26 PM, Myklebust, Trond wrote:
> > > On Sun, 2012-03-04 at 17:58 -0500, Steve Dickson wrote:
> > >> So to restate... this normalizing of the path names (aka striping 
> > >> multiple slashes or added the leading slash) only need to occur on 
> > >> (successful) v4 mounts... Although the former would not be an 
> > >> problem with v2/v3 mounts but its not needed....
> > > 
> > > Normalising for v4 only is OK as far as I'm concerned, but as an
> > > alternative: is there any reason why you can't just grab the path from
> > > '/proc/mounts'?

I don't know where it grabs the path (mtab vs proc file), but it
probably doesn't matter. Either one should work for umount. AFAIR, it is
only the matching entries issue as the umount needs to delete the
correct entry from matb.  In other words, nfs umount bails out without
calling umount when there is no matching entry.

Thanks, Malahal.

