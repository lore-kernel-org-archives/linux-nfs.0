Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28139 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754634AbaCMRlP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2014 13:41:15 -0400
Subject: Re: [PATCH v2 0/5] NFSv4 rpc.idmapd plugin
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, Noam Meltzer <noam@primarydata.com>,
        linux-nfs@vger.kernel.org, sssd-devel@lists.fedorahosted.org
In-Reply-To: <20140313172531.GA7124@fieldses.org>
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
	 <5321CDB6.7010803@RedHat.com>
	 <1394729939.32465.231.camel@willson.li.ssimo.org>
	 <20140313172531.GA7124@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 13 Mar 2014 13:41:02 -0400
Message-ID: <1394732462.32465.235.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-03-13 at 13:25 -0400, J. Bruce Fields wrote:
> On Thu, Mar 13, 2014 at 12:58:59PM -0400, Simo Sorce wrote:
> > On Thu, 2014-03-13 at 11:24 -0400, Steve Dickson wrote:
> > 
> > > V4 servers now have an option of returning a uid string (aka "3606")
> > > where the NFS client just converts that into the uid.
> > 
> > Can the client tell the server *not to do that* ?
> 
> The client can use kerberos, in which case the server won't do that.

This is sufficient, thanks.

> Other than that, no, the behavior can only be controlled by server-side
> configuration.

A little sub-optimal if the server can do either but the client can have
a choice, but ok.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

