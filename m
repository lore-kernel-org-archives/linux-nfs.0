From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 16:07:59 -0800
Message-ID: <1231286879.14345.194.camel@localhost>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com>
	 <1231274682.20316.65.camel@heimdal.trondhjem.org>
	 <20090106215831.GE18147@us.ibm.com> <m1eizg11fy.fsf@frodo.ebiederm.org>
	 <1231283734.8041.6.camel@heimdal.trondhjem.org>
	 <20090106233238.GD13785@fieldses.org>
	 <1231284943.8041.8.camel@heimdal.trondhjem.org>
	 <20090106235322.GE13785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:49598 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752949AbZAGAIC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 19:08:02 -0500
In-Reply-To: <20090106235322.GE13785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 18:53 -0500, J. Bruce Fields wrote:
> On Tue, Jan 06, 2009 at 06:35:43PM -0500, Trond Myklebust wrote:
> > On Tue, 2009-01-06 at 18:32 -0500, J. Bruce Fields wrote:
> > > On Tue, Jan 06, 2009 at 06:15:34PM -0500, Trond Myklebust wrote:
> > > > On Tue, 2009-01-06 at 15:04 -0800, Eric W. Biederman wrote:
> > > > > That implies to me you want to capture the value at mount time, and to
> > > > > pass it in to the rpc_call creation, and only at very specific well
> > > > > defined points where we interact with user space should we examine
> > > > > current->utsname().  At which point there should be no question
> > > > > of current->utsname() is valid as the user space process is alive.
> > > > 
> > > > Why pretend that the filesystem is owned by a particular namespace? It
> > > > can, and will be shared among many containers...
> > > 
> > > If the only purpose of this is to fill in the auth_unix cred then
> > > shouldn't it be part of whatever cred structures are passed around?
> > 
> > So how does tracking it in a shared structure like the rpc_client help?
> > If you consider it to be part of the cred, then it needs to be tracked
> > in the cred...
> 
> Right, that's what I meant.
> 
> It seems like overkill, though.  Does anyone actually care whether these
> names are right?

That's certainly a tempting angle. However we may not "control" the
server code -- couldn't there be some oddball (maybe even proprietary)
NFS servers out there that users do care about interacting with?

Cheers,
	-Matt Helsley


