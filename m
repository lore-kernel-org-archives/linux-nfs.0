Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.65.40]:45279 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099Ab0GGRNO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 13:13:14 -0400
Subject: Re: [PATCH 05/10] KConfig: Add KConfig entries for Labeled NFS
From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        sds@tycho.nsa.gov, matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
In-Reply-To: <20100707165602.GC28815@fieldses.org>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	 <1278513086-23964-6-git-send-email-dpquigl@tycho.nsa.gov>
	 <20100707165602.GC28815@fieldses.org>
Content-Type: text/plain
Date: Wed, 07 Jul 2010 13:05:21 -0400
Message-Id: <1278522321.2494.104.camel@moss-terrapins.epoch.ncsc.mil>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-07-07 at 12:56 -0400, J. Bruce Fields wrote:
> On Wed, Jul 07, 2010 at 10:31:21AM -0400, David P. Quigley wrote:
> > This patch adds two entries into the fs/KConfig file. The first entry
> > NFS_V4_SECURITY_LABEL enables security label support for the NFSv4 client while
> > the second entry NFSD_V4_SECURITY_LABEL enables security labeling support on
> > the server side.
> 
> Will there also be some way to turn these on and off at run-time (maybe
> for particular exports or filesystems?)
> 
> And if so, will there be any reason not to have this on all the time?  I
> don't think we'll want a config option for every future possible NFSv4.x
> feature.

The way the code currently works is if you want security labeling on an
export you need to put the sec_label option on your export line (we have
a modified nfs-utils to accept that option). This will set the
particular capability flag for security labeling support on the server.
After that it works like any other capability. I don't think there is a
need to turn it on/off without reexporting the file system especially
since I'm not sure if there is a way to regrab the server capabilities
after the initial mount. I don't see why we couldn't not have this on at
all times from a kconfig perspective. I can make sure that the code is
prepared to always be there and handle when there is no need for it to
be used.

A little bit of a background on how SELinux will handle this (other LSMs
are welcome to do what they like).

If you want to turn security labeling on/off on a per export basis we
have the sec_label export option for that. If you have a file system
that is exported with sec_label and you don't want to use security
labels from the server SELinux provides a capability called context
mounts. It allows us to set the label for every file on that mount point
regardless of whether the file system provides other labeling
capabilities. So if we have a server exporting /www with security labels
and we don't want to trust it I would use a mount command like the one
below to set the security label for the entire mount

mount -t nfs4 -o context="system_u:object_r:httpd_sys_content_t:s0"
localhost:/www /mnt/www

Dave



