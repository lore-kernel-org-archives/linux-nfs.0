Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39522 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754330AbaCMRZd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2014 13:25:33 -0400
Date: Thu, 13 Mar 2014 13:25:31 -0400
To: Simo Sorce <simo@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>, Noam Meltzer <noam@primarydata.com>,
        linux-nfs@vger.kernel.org, sssd-devel@lists.fedorahosted.org
Subject: Re: [PATCH v2 0/5] NFSv4 rpc.idmapd plugin
Message-ID: <20140313172531.GA7124@fieldses.org>
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
 <5321CDB6.7010803@RedHat.com>
 <1394729939.32465.231.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1394729939.32465.231.camel@willson.li.ssimo.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 13, 2014 at 12:58:59PM -0400, Simo Sorce wrote:
> On Thu, 2014-03-13 at 11:24 -0400, Steve Dickson wrote:
> 
> > V4 servers now have an option of returning a uid string (aka "3606")
> > where the NFS client just converts that into the uid.
> 
> Can the client tell the server *not to do that* ?

The client can use kerberos, in which case the server won't do that.

Other than that, no, the behavior can only be controlled by server-side
configuration.

--b.
