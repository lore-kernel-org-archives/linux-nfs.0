Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:57035 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab1FZN63 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jun 2011 09:58:29 -0400
Date: Sun, 26 Jun 2011 09:58:24 -0400
From: Jim Rees <rees@umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: Re: [PATCH] manpage: add info about IPv6 configuration to exports(5)
Message-ID: <20110626135824.GA1777@merit.edu>
References: <1308597604-1198-1-git-send-email-jlayton@redhat.com>
 <20110620153834.126e6bbc@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110620153834.126e6bbc@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff Layton wrote:

  > +/foo            [2001:321:9:e54::/64](rw) 192.168.1.0/24(rw)
  >  '''/pub/private    (noaccess)
  >  .fi
  >  .PP
  > @@ -501,7 +502,8 @@ option in this entry also allows clients with NFS implementations that
  >  don't use a reserved port for NFS.
  >  The sixth line exports a directory read-write to the machine 'server'
  >  as well as the `@trusted' netgroup, and read-only to netgroup `@external',
  > -all three mounts with the `sync' option enabled.
  > +all three mounts with the `sync' option enabled. The seventh line exports
  > +a directory to both an IPv6 and an IPv4 subnet.
  >  ''' The last line denies all NFS clients
  >  '''access to the private directory.
  >  '''.SH CAVEATS
  
  Self NAK on this, as brackets don't seem to be required after all. I'll
  respin and resend once I get that straightened out.

Are the brackets allowed, and if so, must the mask be inside the brackets or
can it be outside?  And should this be documented?

This came up on another server implementation recently and I couldn't find
any spec that describes the brackets.  It would be nice to achieve some
kind of standardization.
