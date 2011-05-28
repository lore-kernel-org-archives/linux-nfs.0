Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:58581 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373Ab1E1N34 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 May 2011 09:29:56 -0400
Date: Sat, 28 May 2011 09:29:53 -0400
From: Jim Rees <rees@umich.edu>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2] rpc.mountd: let mountd consult /etc/services for port
Message-ID: <20110528132953.GA8525@merit.edu>
References: <4DAD48C7.9090808@cn.fujitsu.com>
 <4DE0C380.7040608@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DE0C380.7040608@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Mi Jinlong wrote:

  At RHEL, if user set port for mountd at /etc/services as 
  "mount   12345/tcp", mountd should be bind to 12345, but the 
  latest nfs-utils, mountd get a rand port, not 12345.
  
  This patch make sure mountd be bind to the port which was set
  at /etc/service.

Is this really such a good idea?  I would find this behavior surprising.  I
expect listeners to either use a well-known port, in which case they look in
/etc/services and fall back to a compiled-in constant (like telnet or ftp),
or use an ephemeral port, in which case they don't even look at
/etc/services.  This patch would change mountd so that its behavior
(well-known versus ephemeral) depends on /etc/services rather than a
run-time option.

The change in behavior would not be immediately obvious, either, because who
is going to notice that mountd is now on a well-known port?

You could argue that the admin would have to add a line to /etc/services for
anything to change, and I guess I could be convinced.  But are you sure some
distro packaging person isn't going to put that line in without
understanding the implications?

Yes, I know putting mountd on a random port isn't going to thwart a
determined hacker.  I'm thinking of the nuisance factor.  Consider ssh.
It's a secure protocol, so there isn't really a security risk with leaving
it on port 22, but sometimes you have to move it off to keep the log files
from filling up with crap.

Here's an alternate proposal.  Have the "-p" option take either a number or
a name.  If it's a name, look it up in /etc/services.
