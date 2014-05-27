Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752719AbaE0UCp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2014 16:02:45 -0400
Subject: Re: [SSSD] [PATCH v2 0/5] NFSv4 rpc.idmapd plugin
From: Simo Sorce <simo@redhat.com>
To: Jakub Hrozek <jhrozek@redhat.com>
Cc: Development of the System Security Services Daemon
	<sssd-devel@lists.fedorahosted.org>,
        Noam Meltzer <noam@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
In-Reply-To: <20140527194624.GY6330@hendrix.brq.redhat.com>
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
	 <5321CDB6.7010803@RedHat.com>
	 <1394729939.32465.231.camel@willson.li.ssimo.org>
	 <20140313172531.GA7124@fieldses.org>
	 <1394732462.32465.235.camel@willson.li.ssimo.org>
	 <CAOoFWK_uNLEim7MH=K=Ojge_KjcJk6V7p1-LFcYNPC9=fZ90fQ@mail.gmail.com>
	 <532AF1D1.7070400@RedHat.com>
	 <20140527194624.GY6330@hendrix.brq.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 May 2014 16:02:36 -0400
Message-ID: <1401220956.2598.36.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-05-27 at 21:46 +0200, Jakub Hrozek wrote:
> On Thu, Mar 20, 2014 at 09:49:05AM -0400, Steve Dickson wrote:
> > 
> > 
> > On 03/20/2014 03:33 AM, Noam Meltzer wrote:
> > > 
> > > 
> > > 
> > > On Thu, Mar 13, 2014 at 7:41 PM, Simo Sorce <simo@redhat.com <mailto:simo@redhat.com>> wrote:
> > > 
> > >     On Thu, 2014-03-13 at 13:25 -0400, J. Bruce Fields wrote:
> > >     > On Thu, Mar 13, 2014 at 12:58:59PM -0400, Simo Sorce wrote:
> > >     > > On Thu, 2014-03-13 at 11:24 -0400, Steve Dickson wrote:
> > >     > >
> > >     > > > V4 servers now have an option of returning a uid string (aka "3606")
> > >     > > > where the NFS client just converts that into the uid.
> > >     > >
> > >     > > Can the client tell the server *not to do that* ?
> > >     >
> > >     > The client can use kerberos, in which case the server won't do that.
> > > 
> > >     This is sufficient, thanks.
> > > 
> > >     > Other than that, no, the behavior can only be controlled by server-side
> > >     > configuration.
> > > 
> > >     A little sub-optimal if the server can do either but the client can have
> > >     a choice, but ok.
> > > 
> > > 
> > > Sorry for the late response. A misplaced email filtering rule had moved it away from my inbox.
> > > How can we push this forward?
> > > 
> > Not sure since I don't maintain any of the code these patches change... 
> > 
> > steved.
> 
> Does the code work with the current NFS idmap implementation or are
> there any changes on either side needed?
> 
> Simo, are there still any issues that would prevent us from merging the
> code into SSSD?

I am not aware of any issue, but I have not found any time to do any
testing, sorry :-/

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

