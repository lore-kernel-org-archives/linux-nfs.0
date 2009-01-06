From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 18:35:43 -0500
Message-ID: <1231284943.8041.8.camel@heimdal.trondhjem.org>
References: <20090106011314.534653345@us.ibm.com>
	<20090106011314.961946803@us.ibm.com>
	<20090106200229.GA17031@us.ibm.com>
	<1231274682.20316.65.camel@heimdal.trondhjem.org>
	<20090106215831.GE18147@us.ibm.com> <m1eizg11fy.fsf@frodo.ebiederm.org>
	<1231283734.8041.6.camel@heimdal.trondhjem.org>
	<20090106233238.GD13785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <containers-bounces@lists.linux-foundation.org>
In-Reply-To: <20090106233238.GD13785@fieldses.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Sender: containers-bounces@lists.linux-foundation.org
Errors-To: containers-bounces@lists.linux-foundation.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 18:32 -0500, J. Bruce Fields wrote:
> On Tue, Jan 06, 2009 at 06:15:34PM -0500, Trond Myklebust wrote:
> > On Tue, 2009-01-06 at 15:04 -0800, Eric W. Biederman wrote:
> > > That implies to me you want to capture the value at mount time, and to
> > > pass it in to the rpc_call creation, and only at very specific well
> > > defined points where we interact with user space should we examine
> > > current->utsname().  At which point there should be no question
> > > of current->utsname() is valid as the user space process is alive.
> > 
> > Why pretend that the filesystem is owned by a particular namespace? It
> > can, and will be shared among many containers...
> 
> If the only purpose of this is to fill in the auth_unix cred then
> shouldn't it be part of whatever cred structures are passed around?

So how does tracking it in a shared structure like the rpc_client help?
If you consider it to be part of the cred, then it needs to be tracked
in the cred...

Trond
