Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47917 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755982Ab3CSPXH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 11:23:07 -0400
Date: Tue, 19 Mar 2013 11:23:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/11] NFSv4.1: Enable open-by-filehandle
Message-ID: <20130319152304.GG7912@fieldses.org>
References: <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-9-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com>
 <20130319140901.GB7912@fieldses.org>
 <1363702570.7515.6.camel@leira.trondhjem.org>
 <20130319143236.GD7912@fieldses.org>
 <1363704100.7515.12.camel@leira.trondhjem.org>
 <20130319145035.GE7912@fieldses.org>
 <1363706205.7515.43.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1363706205.7515.43.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 19, 2013 at 03:16:46PM +0000, Myklebust, Trond wrote:
> On Tue, 2013-03-19 at 10:50 -0400, J. Bruce Fields wrote:
> > On Tue, Mar 19, 2013 at 02:41:42PM +0000, Myklebust, Trond wrote:
> > > On Tue, 2013-03-19 at 10:32 -0400, J. Bruce Fields wrote:
> > > > (Sorry for the digression, I was just trying to decide whether I can get
> > > > away with turning on 4.1 by default before implementing SP4_MACH_CRED or
> > > > GSS on the backchannel....)
> > > 
> > > If you don't, could you please at least offer up a module parameter that
> > > allows me to do that? The current thing is a PITA, since it isn't
> > > supported by any distro scripts, and it requires you to switch off the
> > > server in order to change the version pseudofile contents.
> > 
> > The module parameter on its own wouldn't help with that.
> > 
> > We could probably fix the pseudofile interface to allow changing the
> > version on the fly.
> > 
> > My vague plan was to teach rpc.nfsd to read this (and other parameters)
> > from a config file, so then it'd be "vi /etc/nfsd && service nfsd
> > restart" or equivalent.
> > 
> > So is the main thing you want a more convenient interface or a way to
> > change it without rebooting?
> 
> Basically, all I want is to enable 4.1 permanently on those servers that
> I want to use for NFSv4.1 testing.
> 
> An --enable-nfs-version option for rpc.nfsd that acts together with
> --no-nfs-version as a convenient interface for /proc/fs/nfsd/versions
> would work fine too. All distro configuration scripts that I'm aware of
> allow you to specify optional arguments to rpc.nfsd.

Right, got it.  Yes, that's on my todo list.

(But, of course, patches welcomed if someone wants to beat me to it.)

--b.
