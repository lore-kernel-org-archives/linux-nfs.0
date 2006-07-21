From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 21 Jul 2006 14:10:58 -0400
Message-ID: <20060721181058.GA17169@fieldses.org>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	Sam Falkner <Sam.Falkner@Sun.COM>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>, "Pawlowski,
	Brian" <beepy@netapp.com>, Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfsv4-bounces@ietf.org>
To: "Noveck, Dave" <Dave.Noveck@netapp.com>
In-Reply-To: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Jul 21, 2006 at 11:10:04AM -0400, Noveck, Dave wrote:
> > Rethinking, it would be preferable to have the ACL specification  
> > specify requirements, and have the algorithms serve as examples.  
> 
> I think the requirements that the algorithms are intended to address,
> would be helpful in understanding, whether the algorithms are 
> examples or are mandatory.

Yes.  My point wasn't necessarily that they should not be mandatory
(though I think they probably shouldn't be--I'm not yet convinced
they're actually correct), but that we need clarified whether they're
mandatory or not, and what requirements they're meant to meet, before we
can evaluate them properly.

> I think this would complicate understanding and review.  Even if
> the algorithms are examples and not mandatory, I would imagine
> they would be helpful in understanding the requirements and their
> implications, and if they are helpful, they should be in the spec,
> with an indication that they are illustrative and not mandatory.

But I don't care whether they're incorporated by reference or copying.

--b.

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
