From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Thoughts about cache consistency and directories in particular.
Date: Thu, 23 Apr 2009 18:07:42 -0400
Message-ID: <20090423220742.GD1906@fieldses.org>
References: <18846.4842.625445.980681@notabene.brown> <20090220182350.GB1104@fieldses.org> <18847.2286.101191.989726@notabene.brown> <20090220201424.GG1104@fieldses.org> <18847.6886.50844.260910@notabene.brown> <20090421214349.GD27411@fieldses.org> <20090423213436.GA1906@fieldses.org> <1240523577.8583.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	Theodore Tso <tytso@mit.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40223 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759716AbZDWWHq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 18:07:46 -0400
In-Reply-To: <1240523577.8583.13.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 05:52:57PM -0400, Trond Myklebust wrote:
> On Thu, 2009-04-23 at 17:34 -0400, J. Bruce Fields wrote:
> > On Tue, Apr 21, 2009 at 05:43:49PM -0400, bfields wrote:
> > > Actually, I did this and then realized: I'm using IS_I_VERSION(inode) to
> > > turn on use of the i_version as the change attribute on both files and
> > > directories.  But it actually only makes a difference for files.
> > > 
> > > So I guess I should just be using i_version as the change attribute
> > > unconditionally for directories?  (Will that work on any filesystem?)
> > 
> > I'm still curious about this.
> 
> Few of the common filesystems actually store dir->i_version on permanent
> storage,

Hopefully ext4 is, at least in the IS_I_VERSION(inode) case?

--b.

> and none of the ramfs type filesystems appear to set
> dir->i_version at all.
> 
> Cheers
>   Trond
> 
