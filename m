Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39092 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464AbbIIJRo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2015 05:17:44 -0400
Date: Wed, 9 Sep 2015 11:16:57 +0200
From: David Sterba <dsterba@suse.cz>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v1 9/8] copy_file_range.2: New page documenting
 copy_file_range()
Message-ID: <20150909091657.GD8891@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1441397823-1203-10-git-send-email-Anna.Schumaker@Netapp.com>
 <20150904213856.GC10391@birch.djwong.org>
 <55EEF8E3.8030501@Netapp.com>
 <20150908203918.GB30681@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150908203918.GB30681@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 08, 2015 at 01:39:18PM -0700, Darrick J. Wong wrote:
> > >> +The file descriptors must not refer to the same file.
> > > 
> > > Why?  btrfs (and XFS) reflink can handle the case of a file sharing blocks
> > > with itself.
> > 
> > I've never really thought about it... Zach had that in his initial
> > submission, so mentioned it in the man page.  Should I remove that bit?
> 
> Yes, please!
> 
> I could be wrong, but I think btrfs only started supporting files that share
> blocks with themselves relatively recently(?)

The support was added into the cloning ioctl itself, otherwise same-file
clones were always possible with a sidestep using another file.
