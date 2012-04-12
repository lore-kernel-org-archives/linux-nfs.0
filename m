Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52828 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754124Ab2DLVZk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Apr 2012 17:25:40 -0400
Date: Thu, 12 Apr 2012 17:25:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bernd Schubert <bernd.schubert@fastmail.fm>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        "J. Bruce Fields" <bfields@redhat.com>, "Ted Ts'o" <tytso@mit.edu>,
        Jan Kara <jack@suse.cz>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        yong.fan@whamcloud.com, sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120412212534.GF6667@fieldses.org>
References: <20120312154921.GB17153@pad.fieldses.org>
 <20120312222250.GD8991@fieldses.org>
 <20120313200117.GA21991@fieldses.org>
 <4F5FA827.8020606@itwm.fraunhofer.de>
 <20120313203446.GB21991@fieldses.org>
 <4F5FB771.9010805@fastmail.fm>
 <20120313212947.GK31995@pad.fieldses.org>
 <4F60AC0D.9020204@itwm.fraunhofer.de>
 <20120412204948.GE6667@fieldses.org>
 <4F8747A1.8060800@fastmail.fm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F8747A1.8060800@fastmail.fm>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 12, 2012 at 11:22:41PM +0200, Bernd Schubert wrote:
> On 04/12/2012 10:49 PM, J. Bruce Fields wrote:
> > Stupid question: is there any fundamental feature of ext4 this depends
> > on, or would this fix work equally well for fs/ext3?
> 
> First of all, Bruce and Ted, thanks a lot for your patience with those
> patches!
> 
> I have not looked into it in detail yet, but it should be possible to
> back port it to ext3. I don't think there is anything that would depend
> on ext4. I also have ext3 on my todo list, but I first wanted to have it
> in ext4 (in the sense of stability of ext3, if there still should be a
> bug...) and I think for 3.4 it is too late now anyways. So unless there
> are objections, lets target the back port to ext3 for 3.5?

That sounds sensible, thanks!

--b.
