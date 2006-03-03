From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv3 + ACL + XFS?
Date: Fri, 3 Mar 2006 11:30:40 -0500
Message-ID: <20060303163040.GA32552@fieldses.org>
References: <200603020703.26338.gopal@nerur.com>
	<200603030802.37899.gopal@nerur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Gopal Santhanam <gopal@nerur.com>
In-Reply-To: <200603030802.37899.gopal@nerur.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Mar 03, 2006 at 08:02:37AM -0800, Gopal Santhanam wrote:
> On Thursday 02 March 2006 07:03, Gopal Santhanam wrote:
> > Hi all,
> >
> > I am successful in exporting an EXT3 partition with ACLs
> > through NFSv3.
> >
> > However, I cannot do the same for an XFS partition with ACLs. 
> > I did a quick search on the web and did not easily find any
> > information on this.  What's the status on this?  Is there a
> > way I can get this to work through proper configuration?

Hm, odd, both filesystems appear to support the same underlying
interface for getting and setting ACLs, but I can confirm that ACLs from
XFS aren't working over NFS.  I'll investigate....

--b.
