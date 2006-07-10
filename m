From: Spencer Shepler <spencer.shepler@sun.com>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 10:25:00 -0500
Message-ID: <20060710152500.GA1510@137.96.227.10.in-addr.arpa>
References: <C98692FD98048C41885E0B0FACD9DFB8028CEAAC@exnane01.hq.netapp.com>
	<200607101007.43824.agruen@suse.de>
	<20060710142445.GB978@fieldses.org>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@ietf.org>
To: nfsv4@ietf.org
In-Reply-To: <20060710142445.GB978@fieldses.org>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, J. Bruce Fields wrote:
> On Mon, Jul 10, 2006 at 10:07:43AM +0200, Andreas Gruenbacher wrote:
> >  - define mechanisms which can be used to achieve *full* POSIX compliance of
> >    NFSv4.1 ACLs, on systems which implement a POSIX compliant ACL model,
> 
> All of these "POSIX" requirements (including the language about
> additional and alternate access control mechanisms) are from the one
> draft, right?
> 
> In other words, this is stuff people tried and failed to come to some
> agreement on in the past.
> 
> Other things being equal, I've got nothing against full compliance with
> that draft, but careless use of the word posix here may make it look
> like a bigger requirement than it really is.

I would like to echo that sentiment.  There are Posix "draft" ACLs.
As we know, they were part of a larger document that were never agreed to.

The way I have been looking at the problem is that we have NFSv4 ACLs
that need further interpretation to make the specification more useful.
We also have the issue of dealing with NFSv4 ACLs in environments like
the Posix APIs.

Spencer

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
