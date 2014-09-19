Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54713 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754306AbaISQgS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 12:36:18 -0400
Date: Fri, 19 Sep 2014 12:36:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH 0/2] Use the gssproxy damon for GSSAPI credentials
Message-ID: <20140919163617.GB16658@fieldses.org>
References: <1411131103-17254-1-git-send-email-steved@redhat.com>
 <20140919155733.GA16658@fieldses.org>
 <541C5A55.7010403@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <541C5A55.7010403@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 19, 2014 at 12:31:17PM -0400, Steve Dickson wrote:
> 
> 
> On 09/19/2014 11:57 AM, J. Bruce Fields wrote:
> > On Fri, Sep 19, 2014 at 08:51:41AM -0400, Steve Dickson wrote:
> >> The gssproxy(8) daemon is now how the managing of GSSAPI 
> >> credentials should be done. 
> >>
> >> These to patches has the nfs-server systemd script start 
> >> gssproxy instead of rpc.svcgssd and removes the building 
> >> and installation of rpc.svcgssd.
> >>
> >> For now I'm leaving the source files... Just in case... ;-)
> > 
> > If nothing else, we'd like to keep support for older kernels for a
> > while.
> Good point... I should probably make this a configurable...
> something like --enable_svcgssd and have it off by default...

Sounds fine.

--b.
