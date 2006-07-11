From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 20:09:47 -0400
Message-ID: <20060711000946.GA1440@fieldses.org>
References: <C98692FD98048C41885E0B0FACD9DFB8028CEAAC@exnane01.hq.netapp.com>
	<200607101007.43824.agruen@suse.de>
	<20060710142445.GB978@fieldses.org>
	<200607110148.25788.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lisa Week <Lisa.Week@sun.com>, nfsv4@ietf.org,
	Sam Falkner <Sam.Falkner@sun.com>, nfs@lists.sourceforge.net,
	"Noveck, Dave" <Dave.Noveck@netapp.com>,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfsv4-bounces@ietf.org>
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200607110148.25788.agruen@suse.de>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Jul 11, 2006 at 01:48:25AM +0200, Andreas Gruenbacher wrote:
> On Monday, 10. July 2006 16:24, J. Bruce Fields wrote:
> > On Mon, Jul 10, 2006 at 10:07:43AM +0200, Andreas Gruenbacher wrote:
> > >  - define mechanisms which can be used to achieve *full* POSIX compliance
> > > of NFSv4.1 ACLs, on systems which implement a POSIX compliant ACL model,
> >
> > All of these "POSIX" requirements (including the language about
> > additional and alternate access control mechanisms) are from the one
> > draft, right?
> 
> No, *none* of what I am referring to as POSIX requirements is from 1003.1e 
> draft 17 (withdrawn) or from other drafts, it's all from IEEE Std 1003.1, 
> 2004 edition (which is IEEE Std 1003.1-2001 (POSIX) with corrigenda).

Argh, I see, you're right.  I'd still be willing to give up some degree
of posix compliance if it would help get simpler ACLs....

> Look up the following sections in the definitions volume:
> 
> 3.4 Additional File Access Control Mechanism
> 3.12 Alternate File Access Control Mechanism
> 3.166 File Group Class
> 3.172 File Other CLass
> 3.173 File Owner Class
> 3.174 File Permission Bits
> 4.4 File Access Permissions

Thanks!

--b.

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
