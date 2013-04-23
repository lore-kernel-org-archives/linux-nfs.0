Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756593Ab3DWPqs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 11:46:48 -0400
Message-ID: <5176ACE5.2020207@RedHat.com>
Date: Tue, 23 Apr 2013 11:46:45 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/19] lnfs: 3.9-rc5 release
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com> <20130410150940.GB24404@pad.fieldses.org>
In-Reply-To: <20130410150940.GB24404@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/04/13 11:09, J. Bruce Fields wrote:
> On Tue, Apr 02, 2013 at 05:45:41PM -0400, Steve Dickson wrote:
>> > From: Steve Dickson <steved@redhat.com>
>> > 
>> > Here is the next release of the Label NFS patches 
>> > forward ported to linux-3.9-rc3.
>> > 
>> > I decided to include the the v4.2 enabling patches since 
>> > I'm doing all my testing with both sets so at this point 
>> > I don't think it makes sense to separate them. Plus I'm
>> > hoping they will take care of the SETATTR problem Bruce was 
>> > seeing since label attributes were leaking into the bitmask
>> > when they were not suppose to. 
> Still getting a failure.  All you need to do is something like:
> 
> 	git clone git://linux-nfs.org/~bfields/pynfs.git
> 	cd pynfs
> 	./setup.py build
> 	./setup.py build_ext --inplace
> 	./nfs4.0/testserver.py pip1:/path/to/export/tmpdir ---maketree --rundeps SATT13
Unfortunately, I'm not able to reproduce this error on any of the following kernels
* No labels 
* No labels configured
    # CONFIG_NFS_V4_2 is not set
    # CONFIG_NFSD_V4_SECURITY_LABEL is not set
* Labels configured 
   CONFIG_NFS_V4_2=y
   CONFIG_NFS_V4_SECURITY_LABEL=y

What exactly was failing?

steved.
