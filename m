From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs4 write delegation status
Date: Thu, 23 Jul 2009 09:00:39 -0400
Message-ID: <20090723130039.GB22626@fieldses.org>
References: <fe2cbb740907211447t4dfcc0dara63bb96648599638@mail.gmail.com>
	<20090722163810.GB4491@fieldses.org>
	<OF97D5D1D5.E19FBA13-ONC12575FC.002CE971-C12575FC.002D0D78@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-nfs-owner@vger.kernel.org
To: Eric Veith <ERVEITH@de.ibm.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <OF97D5D1D5.E19FBA13-ONC12575FC.002CE971-C12575FC.002D0D78@de.ibm.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 23, 2009 at 10:12:05AM +0200, Eric Veith wrote:
> Hello,
> 
> > I really don't want to enable write delegations until we figure out how
> > to enforce them correctly against local (non-nfs) users of the exported
> > filesystem as well.  In addition to breaking delegations on read opens,
> > that means breaking delegations or doing a cb_getattr on operations like
> > stat.
> 
> do you know whether there are local FS where the maintainers at least plan
> to incorporate delegations?

Local filesystems don't need support from the filesystem itself; the
only modifications necessary should be to the vfs.

We have patches that do that for read delegations:

	http://git.linux-nfs.org/?p=bfields/linux-topics.git;a=shortlog;h=refs/heads/leases

but they still have a few problems.  I hope to get them out for review
soon.

Write delegations are more difficult.  Distributed filesystems will also
be harder.

--b.
