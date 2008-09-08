From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount
	namespace is unshared
Date: Mon, 8 Sep 2008 10:43:53 -0500
Message-ID: <20080908154353.GA21168@us.ibm.com>
References: <48C52B29.4020204@fr.ibm.com> <20080908151932.GA19023@us.ibm.com> <48C546C0.504@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:49888 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768AbYIHPn4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Sep 2008 11:43:56 -0400
In-Reply-To: <48C546C0.504-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn wrote:
> > Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> >> On a system with nfs mounts, if a task unshares its mount namespace,
> >> a oops can occur when the system is rebooted if the task is the last
> >> to unreference the nfs mount. It will try to create a rpc request
> >> using utsname() which has been invalidated by free_nsproxy().
> >>
> >> The patch fixes the issue by using the global init_utsname() but at
> >> the same time, it breaks the capability of identifying rpc clients
> >> per uts namespace.
> >>
> >> Any better suggestions ?
> > 
> > But the utsname gets freed after the mnt_ns, so the analysis seems
> > wrong somehow.
> 
> yes but switch_task_namespaces() assigns ->nsproxy to NULL. the result
> is the same.
> 
> > I trust addr2line or whatever verified that rpc_create+0x332/0x42f is
> > exactly at the call to utsname()?
> 
> yes. it points to net/sunrpc/clnt.c:216
> 
> 	clnt->cl_nodelen = strlen(utsname()->nodename);

Pavel, at the mini-summit you mentioned sunrpc transports as one
example of the mini-namespaces openvz currently implements.  We
then apparently went off on a bit of a tangent
(http://wiki.openvz.org/Containers/Mini-summit_2008_notes#Namespaces_and_containers)
after Dave asked for a list of mini-namespaces openvz implements.

What exactly is openvz doing with sunrpc transports, and would it
be a better solution to this problem?

thanks,
-serge
