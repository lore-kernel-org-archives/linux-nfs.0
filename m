Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p02c12o144.mxlogic.net ([208.65.145.77]:33795 "EHLO
	p02c12o144.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829Ab2DJUDt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2012 16:03:49 -0400
From: Peter Staubach <pstaubach@exagrid.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Sachin Prabhu <sprabhu@redhat.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>, steved <steved@redhat.com>
Date: Tue, 10 Apr 2012 15:59:05 -0400
Subject: RE: ESTALE errors: What can be done to handle this problem.
Message-ID: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8DC04@IT-1874.Isys.com>
References: <1334073825.2149.29.camel@localhost>
 <1334077062.19865.21.camel@lade.trondhjem.org>
 <20120410190127.GA32661@pad.fieldses.org>
In-Reply-To: <20120410190127.GA32661@pad.fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

In the real world, practically speaking, the infinite loop will not happen.  Eventually, the client will get a lookup and getattr done and return to the application.  Whatever counter value is chosen is wrong.  By definition.

We can all imagine situations and scenarios, but they simply won't happen.  The Solaris kernel is proof of this.  It has contained support to address this situation for many years now and without having a huge hue and cry from its users and at one point, it actually was used by a lot of people.  :-)

I tried to address this situation while I was at Red Hat and finally gave up because no one wanted to solve the problem for real.  This has to be solved in the vfs and system call layers.

		ps


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
Sent: Tuesday, April 10, 2012 3:01 PM
To: Myklebust, Trond
Cc: Sachin Prabhu; Linux NFS mailing list; jlayton@redhat.com; steved
Subject: Re: ESTALE errors: What can be done to handle this problem.

On Tue, Apr 10, 2012 at 04:57:42PM +0000, Myklebust, Trond wrote:
> Handling ESTALE still doesn't guarantee that you can make progress.
> Remove the 'sleep 3' above, and you can theoretically find yourself 
> replaying lookups until the cows come home while that 'stat()' call 
> continues to return ESTALE.
> The bottom line is that NFS is not safe in situations such as the 
> above,

By the way, what precisely are the "situations such as the above"?  Or put in another way, what are the rules users need to know?

("Operations on paths affected by a directory-modifying operation should not be attempted until after sufficient time has passed for the lookup cache to time out"?  No, it should be a weaker rule than that.)

> since we don't have the kind of locking required to guarantee that 
> LOOKUP + GETATTR can be done atomically.

Though all we actually need is a way to hold a temporary reference on the looked up filehandle.  In theory that wouldn't be hard to add?:

	- Clarify that current and saved filehandles shouldn't go stale
	  during the lifetime of a compound.
	- If we also need to hold filehandle references across
	  compounds, introduce new operations for that (and make the
	  references part of the client's leased state)

--b.

> 
> > Is this approach feasible? If not, what else can be done to avoid 
> > this problem.
> 
> If you have workloads such as the above, then I suggest "mount 
> -olookupcache=none". It still won't prevent ESTALE, but at least you 
> ensure that the dentry revalidation always does a full lookup.
> 
> Otherwise, you can do as Jeff suggested: handle the ESTALE at the VFS 
> level, but ensure that you break out of the loop after a limited 
> number of attempts has been made.
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
