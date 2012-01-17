Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:58341 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab2AQQbd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jan 2012 11:31:33 -0500
Date: Tue, 17 Jan 2012 11:31:33 -0500
From: Jim Rees <rees@umich.edu>
To: Sachin Prabhu <sprabhu@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>
Subject: Re: svcgssd: Allow administrators to specify timeout for the cached
 context
Message-ID: <20120117163133.GB3387@umich.edu>
References: <1326800668.2747.55.camel@sprabhu.fab.redhat.com>
 <20120117134951.GA15479@umich.edu>
 <1326814728.2747.59.camel@sprabhu.fab.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1326814728.2747.59.camel@sprabhu.fab.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sachin Prabhu wrote:

  On Tue, 2012-01-17 at 08:49 -0500, Jim Rees wrote:
  > Sachin Prabhu wrote:
  > 
  >   We had a user report that for an export shared with sec=krb5*, any
  >   changes in user credentials(ex: add user to a secondary group) take some
  >   time before they take effect over the NFS share.
  > 
  > Re-authenticating, either by removing the service ticket or by re-running
  > kinit at the client, should also flush the old credentials.  Can you confirm
  > that works?
  
  We have tried it but it doesn't work unless you actually clean up the
  cache on the NFS server with the command 
  echo `date +'%s'` > /proc/net/rpc/auth.rpcsec.context/flush

Bruce, shouldn't this work?  Is this a bug or a feature?
