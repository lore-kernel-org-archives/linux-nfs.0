Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94BF5C43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 20:31:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5F59E20684
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 20:31:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551904272;
	bh=sS0SabldpOE988tR7YkgKM0skb1wFHmx/U8r2+/G6AY=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=fGV2zpwa0w2BEanDuuWbdqZ8A8i4pRCtSIlve3d5GhUGbnTtSptiFeu0SNjd72tFL
	 6HajDJPyjZqgPj2z3eXFUJQtD4zWPs6xWphdpLyEvkm8y+rUMRZze3RJK/pYsuUBsG
	 Iz1aO5VirTYD3jJbQOfWdecFg9/pG96I8T2Acq5g=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728424AbfCFUbL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 15:31:11 -0500
Received: from mail.kernel.org ([198.145.29.99]:52064 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727214AbfCFUbL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 15:31:11 -0500
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1E87E20661;
        Wed,  6 Mar 2019 20:31:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1551904271;
        bh=sS0SabldpOE988tR7YkgKM0skb1wFHmx/U8r2+/G6AY=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=J3Bn7toBWJ7K71Wa7CPvVtLRMznq1DLETldc3EAg2na6+t5TiuD3OZ2ez6aZyF/jO
         nDrR0QCYMxMqZZUQBryUS9U/1DnBlgpADKGKcMDr3HT9Jb+/nJEYbK7NGCBRjF2Aio
         ema5/xSS5py2ksghXHtxAXmkFe1UNGpgEyGjmse0=
Message-ID: <1ade4724a4e505baf7b7c23a76e44d58b931da1f.camel@kernel.org>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
From:   Jeff Layton <jlayton@kernel.org>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Amir Goldstein <amir73il@gmail.com>
Cc:     Jeremy Allison <jra@samba.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, samba-technical@lists.samba.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        devel@lists.nfs-ganesha.org
Date:   Wed, 06 Mar 2019 15:31:08 -0500
In-Reply-To: <20190306151150.GC2426@fieldses.org>
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
         <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
         <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
         <20190208155052.GB20573@fieldses.org>
         <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
         <20190208221239.GA199180@jra3>
         <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
         <20190214210652.GC9216@fieldses.org> <20190305214748.GD27437@fieldses.org>
         <20190306151150.GC2426@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2019-03-06 at 10:11 -0500, J. Bruce Fields wrote:
> On Tue, Mar 05, 2019 at 04:47:48PM -0500, J. Bruce Fields wrote:
> > On Thu, Feb 14, 2019 at 04:06:52PM -0500, J. Bruce Fields wrote:
> > > After this:
> > > 
> > > 	https://marc.info/?l=linux-nfs&m=154966239918297&w=2
> > > 
> > > delegations would no longer conflict with opens from the same tgid.  So
> > > if your threads all run in the same process and you're willing to manage
> > > conflicts among your own clients, that should still allow you to do
> > > multiple opens of the same file without giving up your lease/delegation.
> > > 
> > > I'd be curious to know whether that works with Samba's design.
> > 
> > Any idea whether that would work?
> > 
> > (Easy?  Impossible?  Possible, but realistically the changes required to
> > Samba would be painful enough that it'd be unlikely to get done?)
> 
> Volker reminds me off-list that he'd like to see Ganesha and Samba work
> out an API in userspace first before commiting to a user<->kernel API.
> 
> Jeff, wasn't there some work (on Ceph maybe?) on a userspace delegation
> API?  Is that close to what's needed?
> 

Here's the C headers for that stuff:

    https://github.com/ceph/ceph/blob/7ba6bece4187eda5d05a9b84211fe6ba8dd287bd/src/include/cephfs/libcephfs.h#L1734

It's simple enough and works for us in ganesha, and I think we can
probably adapt it to samba without too much difficulty. The callback
doesn't seem like it'll do for a kernel API though -- you'd almost
certainly need to do something different there (signals? inotify?).

> In any case, my immediate goal is just to get knfsd fixed, which doesn't
> really commit us to anything--knfsd only needs kernel internal
> interfaces.  But it'd be nice to have at least some idea if we're on the
> right track, to save having to redo that work later.
> 


-- 
Jeff Layton <jlayton@kernel.org>

