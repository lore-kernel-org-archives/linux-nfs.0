From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 6 Jan 2009 18:32:38 -0500
Message-ID: <20090106233238.GD13785@fieldses.org>
References: <20090106011314.534653345@us.ibm.com> <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com> <1231274682.20316.65.camel@heimdal.trondhjem.org> <20090106215831.GE18147@us.ibm.com> <m1eizg11fy.fsf@frodo.ebiederm.org> <1231283734.8041.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:55276 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535AbZAFXcu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 18:32:50 -0500
In-Reply-To: <1231283734.8041.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2009 at 06:15:34PM -0500, Trond Myklebust wrote:
> On Tue, 2009-01-06 at 15:04 -0800, Eric W. Biederman wrote:
> > That implies to me you want to capture the value at mount time, and to
> > pass it in to the rpc_call creation, and only at very specific well
> > defined points where we interact with user space should we examine
> > current->utsname().  At which point there should be no question
> > of current->utsname() is valid as the user space process is alive.
> 
> Why pretend that the filesystem is owned by a particular namespace? It
> can, and will be shared among many containers...

If the only purpose of this is to fill in the auth_unix cred then
shouldn't it be part of whatever cred structures are passed around?

But I doubt it's that important to get it right.

--b.
