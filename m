From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: [NFS] NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 14 Jul 2006 15:13:57 -0400
Message-ID: <20060714191357.GJ20999@fieldses.org>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<20060714175930.GD20999@fieldses.org>
	<200607142102.45216.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Falkner <Sam.Falkner@sun.com>, Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@sun.com>,
	nfs@lists.sourceforge.net, nfsv4@ietf.org
Return-path: <nfsv4-bounces@ietf.org>
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200607142102.45216.agruen@suse.de>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Jul 14, 2006 at 09:02:44PM +0200, Andreas Gruenbacher wrote:
> On Friday, 14. July 2006 19:59, J. Bruce Fields wrote:
> > For a server that doesn't support the new attributes, the client still
> > has available any of the current options: give up on non-destructive
> > chmod, or fall back on representing mask bits with DENIES.
> 
> Maybe not what you meant, but shouldn't the client rely on the server to do 
> "the right thing" when it sees a mode SETATTR?

RFC 3530 allows a server to leave named users and groups with
permissions greater than the permissions in the group mode bit, so if a
client wants posix-like behavior it can't count on the server for that.

That said...

> I think it would be a bad idea for the client to guess such details as
> which exact file security model a server implements. Instead, the
> server should be responsible for doing what the client is asking for
> (and erring towards more restrictive permissions if necessary).

... I'm all for declaring 3530 wrong here and insisting that the mode bits
act like a mask, or just not worrying about it and telling users to
check their server's manual very carefully if they depend on the posix
behavior.

--b.

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
