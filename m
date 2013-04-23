Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e32.co.us.ibm.com ([32.97.110.150]:49866 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757062Ab3DWSlk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Apr 2013 14:41:40 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <zohar@linux.vnet.ibm.com>;
	Tue, 23 Apr 2013 12:41:38 -0600
Message-ID: <1366742457.31304.545.camel@falcor1.watson.ibm.com>
Subject: Re: [PATCH 00/19] lnfs: 3.9-rc5 release
From: Mimi Zohar <zohar@linux.vnet.ibm.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Date: Tue, 23 Apr 2013 14:40:57 -0400
In-Reply-To: <5176CD42.4080405@RedHat.com>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
	 <20130410150940.GB24404@pad.fieldses.org> <5176ACE5.2020207@RedHat.com>
	 <20130423160520.GE20622@pad.fieldses.org>
	 <20130423172227.GF20622@pad.fieldses.org> <5176CD42.4080405@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-23 at 14:04 -0400, Steve Dickson wrote:
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

Do you by any chance have EVM enabled?  EVM includes the i_mode in the
HMAC calculation.  Anytime the i_mode changes, the existing HMAC is
verified, before recalculating the HMAC to reflect the change.  The
hooks are there to update the HMAC, when using chmod.

I posted a couple of patches to audit this type of error last week, but
haven't sent a pull request yet.

evm: audit integrity metadata failures
integrity: move integrity_audit_msg()
evm: calculate HMAC after initializing posix acl

thanks,

Mimi


