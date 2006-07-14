From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: [NFS] NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 14 Jul 2006 14:22:45 -0400
Message-ID: <20060714182245.GE20999@fieldses.org>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<20060714175930.GD20999@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Falkner <Sam.Falkner@sun.com>, Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@sun.com>, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@ietf.org>
To: nfsv4@ietf.org
In-Reply-To: <20060714175930.GD20999@fieldses.org>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Jul 14, 2006 at 01:59:30PM -0400, J. Bruce Fields wrote:
> For a client that doesn't support the new attributes, a server can apply
> the mask attributes to the ACL before returning it.  I suppose a
> multi-protocol server would do the same for CIFS clients.

By the way, the proposed protocol behavior here is odd:  the server
returns a different ACL depending on whether the client requested any of
the new mask attributes in the same GETATTR.

But I suppose there are other cases (rdattr_error, maybe some migration
cases??) where what we return can depend in strange ways on which
attributes were requested, so maybe it's not totally without precedent?

--b.

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
