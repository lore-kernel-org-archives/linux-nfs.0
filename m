From: a.gruenbacher@computer.org
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 25 Jul 2006 02:32:36 +0200
Message-ID: <200607250232.37603.a.gruenbacher@computer.org>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
	<20060721181058.GA17169@fieldses.org>
	<85DB3DBD-31B4-4F71-AEFB-5919DC072AD6@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@sun.com>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	"Noveck, Dave" <Dave.Noveck@netapp.com>,
	Spencer Shepler <spencer.shepler@sun.com>,
	"Pawlowski,  Brian" <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5Au8-0006TP-SF
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 17:36:08 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5Au7-00073T-NU
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 17:36:09 -0700
To: Sam Falkner <Sam.Falkner@sun.com>
In-Reply-To: <85DB3DBD-31B4-4F71-AEFB-5919DC072AD6@Sun.COM>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sunday, 23. July 2006 17:47, Sam Falkner wrote:
> On Jul 21, 2006, at 12:10 PM, J. Bruce Fields wrote:
> > On Fri, Jul 21, 2006 at 11:10:04AM -0400, Noveck, Dave wrote:
> >>> Rethinking, it would be preferable to have the ACL specification
> >>> specify requirements, and have the algorithms serve as examples.
> >>
> >> I think the requirements that the algorithms are intended to address,
> >> would be helpful in understanding, whether the algorithms are
> >> examples or are mandatory.
> >
> > Yes.  My point wasn't necessarily that they should not be mandatory
> > (though I think they probably shouldn't be--I'm not yet convinced
> > they're actually correct), but that we need clarified whether they're
> > mandatory or not, and what requirements they're meant to meet,
> > before we can evaluate them properly.
>
> If you have any concerns about their correctness, please let me
> know.  As of now, there has not been a single example showing a flaw
> in them.

There are several flaws, but the lack of clarity on what the algorithms are 
meant to achieve makes this somewhat difficult to see.

> I realize this is difficult without having the requirements listed
> explicitly -- this will be remedied very soon. 

Looking at draft-ietf-nfsv4-minorversion1-04.txt, I disagree with secion 
5.4.1. "Discussion of EVERYONE@". Section 5.5. "Mode Attribute" claims that 
MODE4_RGRP, MODE4_WGRP, MODE4_XGRP apply to the principals identified in the 
owner_group attribute, while it's really the File Group Class according to 
POSIX. From that pretty much follows that the algorithm defined in Section 
5.6.1. is not POSIX compliant: the File Group Class permissions must be a 
superset of the permissions of the permissions granted to all ACEs for a who 
other than OWNER@ and EVERYONE@, and the 5.6.1. algorithm does not guarantee 
this.

Algorithm 5.6.3. is at least problematic because it enforces implementing 
masking of permissions using DENY ACEs, while an alternative design exists 
that achieves the same effects without the disadvantages of those DENY ACEs.

The paragraphs below "3. To conform with POSIX" is lossy, even with the 
six-entry ACL that "2. If there are at least six ACEs" would create, which is 
a very unfavorable property. It also does not cover the case where the owner 
is granted permissions from EVERYONE@ ACEs, or where users or groups matching 
user@domain or group@domain are granted permissions from EVERYONE@ ACEs.

I can't see a compelling reason for requiring the exact six-entry ACL as 
specified in "2. If there are at least six ACEs".

Finally, I have argued why it is wrong to have a mode SETATTR write through to 
USER@, GROUP@, and EVERYONE@ ACEs.

I have described a lot of aspects to the problem both here on this list and in 
a design document, available at 
http://www.suse.de/~agruen/nfs4acl/mapping-nfsv4-acls-to-posix-00.html, and I 
would very much appreciate if you could comment on which parts you disagree 
with and why, in order so that we can come to a conclusion on what we want to 
achieve. I am convinced that once we agree on the basic framework we operate 
within, how to do so will become a lot more obvious.

If you think that I should better provide input in another form then please 
say so, and I will try my best.

Thanks,
Andreas

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
