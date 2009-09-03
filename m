Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Andreas Gruenbacher <agruen@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Date: Thu, 3 Sep 2009 21:09:52 +0200
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20090902164243.GA17126@fieldses.org>
In-Reply-To: <20090902164243.GA17126@fieldses.org>
Message-Id: <200909032109.52615.agruen@suse.de>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@netapp.com, nfsv4@linux-nfs.org,
        sfrench@us.ibm.com
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday, 2 September 2009 18:42:43 J. Bruce Fields wrote:
> On Wed, Sep 02, 2009 at 05:54:20PM +0530, Aneesh Kumar K.V wrote:
> > This patch series implement POSIX ACL support for NFSV4 clients
> > using sideband protocol.
>
> What motivates this?  Who exactly wants this and why?   What would be
> the advantages compared to other options, such as:
>
> 	- native v4 support in filesystems, or
> 	- improved client-side acl tools that provided a user interface
> 	  for v4 acls closer to that for v3 acls, or
> 	- a v4.x extension to add support to the main protocol?

I can't speak for Aneesh, but my expectation is that we'll get native NFSv4 
ACL support eventually, just maybe not in the next few years. Even then, 
systems with native POSIX ACLs will coexist with machines with native NFSv4 
ACLs for a long time, and so NFSv4's lack of decent support for POSIX ACLs is 
a major problem.

I'm not sure what you mean by improved client-side tool. Some information is 
unrecoverably lost when POSIX ACLs are converted into NFSv4 ACLs; no tool on 
the client can make up for this. Besides, presenting server-side POSIX ACLs 
as similar (but not quite identical) NFSv4 ACLs on the client is really not a 
good idea: right now, clients can only guess which NFSv4 ACLs are actually 
POSIX ACLs in disguise.

> Is there interest in implementing this on any OS other than linux, or
> would this be a linux-only extension for the forseeable future?

Good question. I would sure prefer a standard solution to a Linux specific 
hack -- but that being said, I would prefer a solution to the current 
mess ;-)

Thanks,
Andreas
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
