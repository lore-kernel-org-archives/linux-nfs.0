Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17242 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756685Ab3DWRWb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 13:22:31 -0400
Date: Tue, 23 Apr 2013 13:22:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/19] lnfs: 3.9-rc5 release
Message-ID: <20130423172227.GF20622@pad.fieldses.org>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
 <20130410150940.GB24404@pad.fieldses.org>
 <5176ACE5.2020207@RedHat.com>
 <20130423160520.GE20622@pad.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130423160520.GE20622@pad.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 23, 2013 at 12:05:20PM -0400, J. Bruce Fields wrote:
> On Tue, Apr 23, 2013 at 11:46:45AM -0400, Steve Dickson wrote:
> > 
> > 
> > On 10/04/13 11:09, J. Bruce Fields wrote:
> > > On Tue, Apr 02, 2013 at 05:45:41PM -0400, Steve Dickson wrote:
> > >> > From: Steve Dickson <steved@redhat.com>
> > >> > 
> > >> > Here is the next release of the Label NFS patches 
> > >> > forward ported to linux-3.9-rc3.
> > >> > 
> > >> > I decided to include the the v4.2 enabling patches since 
> > >> > I'm doing all my testing with both sets so at this point 
> > >> > I don't think it makes sense to separate them. Plus I'm
> > >> > hoping they will take care of the SETATTR problem Bruce was 
> > >> > seeing since label attributes were leaking into the bitmask
> > >> > when they were not suppose to. 
> > > Still getting a failure.  All you need to do is something like:
> > > 
> > > 	git clone git://linux-nfs.org/~bfields/pynfs.git
> > > 	cd pynfs
> > > 	./setup.py build
> > > 	./setup.py build_ext --inplace
> > > 	./nfs4.0/testserver.py pip1:/path/to/export/tmpdir ---maketree --rundeps SATT13
> > Unfortunately, I'm not able to reproduce this error on any of the following kernels
> > * No labels 
> > * No labels configured
> >     # CONFIG_NFS_V4_2 is not set
> >     # CONFIG_NFSD_V4_SECURITY_LABEL is not set
> > * Labels configured 
> >    CONFIG_NFS_V4_2=y
> >    CONFIG_NFS_V4_SECURITY_LABEL=y
> > 
> > What exactly was failing?
> 
> Sorry I can't find the results right now.  I'll re-run and let you know.

The server is returning -EOPNOTSUPP in response to an nfs4 SETATTR which
sets a mode.

The operation shouldn't be failing, and if it does it should return an
NFS error, not -ERRNO.

I can't reproduce this just by doing chmod on the linux client.  I'm not
sure what pynfs is doing differently to trigger the bug.

--b.
