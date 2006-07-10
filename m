From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 14:57:42 -0400
Message-ID: <20060710185742.GD10035@fieldses.org>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
	<200607091822.44656.agruen@suse.de>
	<B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
	<20060710141541.GA978@fieldses.org>
	<1A2FAFA9-0B94-48FA-8B0B-2A8AC0BE0331@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Spencer Shepler <spencer.shepler@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>, nfsv4@ietf.org,
	Lisa Week <Lisa.Week@Sun.COM>
Return-path: <nfsv4-bounces@ietf.org>
To: Sam Falkner <Sam.Falkner@Sun.COM>
In-Reply-To: <1A2FAFA9-0B94-48FA-8B0B-2A8AC0BE0331@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, Jul 10, 2006 at 09:32:28AM -0600, Sam Falkner wrote:
> On Jul 10, 2006, at 8:15 AM, J. Bruce Fields wrote:
> > As Andreas says, this is what the posix draft would have you do.  It's
> > also what Linux (and, I assume, Solaris) do in the case of posix ACLs.
> 
> Not on Solaris.  With POSIX-draft ACLs, adding user:friend:rw- to a  
> mode rw-r--r-- file still gives you rw-r--r--.  (And as you point out  
> later, these ACLs ain't POSIX.)
...
> > That is how posix acl's work; again, the group mode bit really
> > corresponds to the mask, not to the group acl entry:
...
> Again, not so on Solaris.  I wasn't aware that it was on Linux.  Sigh.

Ugh, sorry, OK, I didn't understand that we had that difference.

Personally, after seeing how complicated this can get, I almost think
I'd rather translate mode bits to NFSv4 ACLs by translating them to the
obvious ACL with 3 ALLOW ACEs.  And I'd rather translate the mask by
just masking out the bits in the obvious way, rather than adding DENY
aces.

At the very least, I'd rather not *forbid* such an implementation.  Yes,
it makes chmod irreversible, and it's wrong in a few rare corner cases,
but there are advantages to being wrong in a way that's simple and easy
to document.

If we're committed to getting the mask ace right, though, I would prefer
to adopt one of Andreas's solutions; they'd allow us to generate much
simpler ACLs.  I actually prefer the first proposal (letting the server
use the mode bits to mask out permissions).  But if we're going to add
explicit mask aces, then please, let's add only one.  I understand the
theoretical advantage to masking out all three classes, but that's
adding too much complexity for a few corner cases, and I don't think
it's going to be easy for users to understand.

We could add a new ACE type (in addition to ALLOW, DENY, AUDIT, ALARM),
and then a client could query the server's ability to represent the mask
with the aclsupport attribute and decide whether it wants to add DENY's
to represent the mask, or just give up on chmod reversibility.

--b.

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
