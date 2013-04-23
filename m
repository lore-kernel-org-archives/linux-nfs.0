Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19366 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757103Ab3DWSPx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 14:15:53 -0400
Date: Tue, 23 Apr 2013 14:15:50 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/19] lnfs: 3.9-rc5 release
Message-ID: <20130423181549.GG20622@pad.fieldses.org>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
 <20130410150940.GB24404@pad.fieldses.org>
 <5176ACE5.2020207@RedHat.com>
 <20130423160520.GE20622@pad.fieldses.org>
 <20130423172227.GF20622@pad.fieldses.org>
 <5176CD42.4080405@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5176CD42.4080405@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 23, 2013 at 02:04:50PM -0400, Steve Dickson wrote:
> On 23/04/13 13:22, J. Bruce Fields wrote:
> >>> What exactly was failing?
> >> > 
> >> > Sorry I can't find the results right now.  I'll re-run and let you know.
> > The server is returning -EOPNOTSUPP in response to an nfs4 SETATTR which
> > sets a mode.
> > 
> > The operation shouldn't be failing, and if it does it should return an
> > NFS error, not -ERRNO.
> > 
> > I can't reproduce this just by doing chmod on the linux client.  I'm not
> > sure what pynfs is doing differently to trigger the bug.
> thanks for talking a look...  
> 
> Hmm... I wonder if the fact nfsd4_set_nfs4_label() is returning 
> -EOPNOTSUPP instead of something like nfserr_attrnotsupp when 
> labels are not configured... Something you've pointed out 
> twice now... 
>     http://www.spinics.net/lists/linux-nfs/msg36104.html
> 
> If it is this problem I wonder why a chmod would not trigger it...

It could happen if sa_label isn't initialized.  Not sure why it would
consistently be NULL in one case but not the other.

--b.
