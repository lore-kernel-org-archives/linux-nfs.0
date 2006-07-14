From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 14 Jul 2006 13:59:30 -0400
Message-ID: <20060714175930.GD20999@fieldses.org>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Falkner <Sam.Falkner@sun.com>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfsv4-bounces@ietf.org>
To: nfsv4@ietf.org
In-Reply-To: <200607071355.30624.agruen@suse.de>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Jul 07, 2006 at 01:55:30PM +0200, Andreas Gruenbacher wrote:
> On Monday, 3. July 2006 23:10, Andreas Gruenbacher wrote:
> > I have been thinking about the problems of interaction between NFSv4 ACLs
> > and POSIX, and particularly about the issue of masking permissions through
> > chmod and after creating files or directories.

So, omitting the details, the idea is to add 3 optional attributes
(owner_class_mask, group_class_mask, and other_class_mask) which limit
the permissions that an ACL can grant to different classes of entities.

For a client that doesn't support the new attributes, a server can apply
the mask attributes to the ACL before returning it.  I suppose a
multi-protocol server would do the same for CIFS clients.

For a server that doesn't support the new attributes, the client still
has available any of the current options: give up on non-destructive
chmod, or fall back on representing mask bits with DENIES.

When client and server support the new mask bits, we get a completely
non-destructive chmod without all the complicated DENY heuristics.

I agree that that would be an improvement.

--b.

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
