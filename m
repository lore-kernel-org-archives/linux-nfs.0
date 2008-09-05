From: Neil Brown <neilb@suse.de>
Subject: Confused about 'sloppy' option parsing in NFS.
Date: Fri, 5 Sep 2008 17:02:00 +1000
Message-ID: <18624.55656.904241.183933@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:58216 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbYIEHCL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Sep 2008 03:02:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The kernel used by OpenSUSE-11.0 complains when automount passes a
'grpid' option.  So I'm looking at backporting the 'sloppy' option
parsing fix.  But I'm confused.

Looking at commit f45663ce5fb30f76a3414ab3ac69f4dd320e760a

It introduced 'sloppy' and 'errors' in nfs_parse_mount_options,
possibly sets them to some non-zero value based on what it finds, and
then does absolutely nothing with them.

nfs_parse_mount_options only returns zero if:
  - memalloc fails
  - security_sb_parse_opts_str fails

But never if there is an unrecognised argument.

This functionality is obviously quite trivial to backport, but I
wonder if it is correct.

Is it just a simple slip up, or am I missing something?

Thanks,
NeilBrown
