Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Wed, 2 Sep 2009 14:27:39 -0400
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Message-ID: <20090902182739.GC17884@fieldses.org>
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20090902164243.GA17126@fieldses.org>
	<20090902174957.GA10701@skywalker.linux.vnet.ibm.com>
In-Reply-To: <20090902174957.GA10701@skywalker.linux.vnet.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@netapp.com, nfsv4@linux-nfs.org,
        sfrench@us.ibm.com, agruen@suse.de
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

On Wed, Sep 02, 2009 at 11:19:57PM +0530, Aneesh Kumar K.V wrote:
> On Wed, Sep 02, 2009 at 12:42:43PM -0400, J. Bruce Fields wrote:
> > On Wed, Sep 02, 2009 at 05:54:20PM +0530, Aneesh Kumar K.V wrote:
> > > This patch series implement POSIX ACL support for NFSV4 clients
> > > using sideband protocol.
> > 
> > What motivates this?  Who exactly wants this and why?   What would be
> > the advantages compared to other options, such as:
> > 
> > 	- native v4 support in filesystems, or
> > 	- improved client-side acl tools that provided a user interface
> > 	  for v4 acls closer to that for v3 acls, or
> > 	- a v4.x extension to add support to the main protocol?
> > 
> > Is there interest in implementing this on any OS other than linux, or
> > would this be a linux-only extension for the forseeable future?
> > 
> > What sideband protocol exactly?  If it's exactly the same protocol as
> > the one used with v3, there must be some slight mismatches: e.g. v4
> > filehandles are allowed to be longer.  How do you deal with these?
> > 
> 
> It is similar to v3 with longer file handle.  Also it doesn't support
> attribute update as a part of the acl calls. I does zap cache and expect
> the client to do another call to get the updated attribute values. Primary
> motivation is to avoid side band rpc having to handle compound request so
> that we can keep it simple.

That doesn't really answer the "motivation" question.

If you really want to do this, writing the code is the easy part.  The
really (extremely) hard part is coming up with good answers to the
questions above.

--b.
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
