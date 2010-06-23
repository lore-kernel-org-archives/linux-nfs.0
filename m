Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:52329 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399Ab0FWXuP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 19:50:15 -0400
Date: Thu, 24 Jun 2010 09:49:58 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: Chuck Lever <chuck.lever@oracle.com>
cc: linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
        Christoph Hellwig <hch@infradead.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        David Patrick Quigley <dpquigl@tycho.nsa.gov>
Subject: Re: [PATCH 3/8][RFC v05] NFSv3: add client implementation of XATTR
 protocol
In-Reply-To: <4C224463.90306@oracle.com>
Message-ID: <alpine.LRH.2.00.1006240851500.1601@tundra.namei.org>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org> <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org> <4C1FC553.4030904@oracle.com> <alpine.LRH.2.00.1006220906300.16648@tundra.namei.org> <4C20D779.5040008@oracle.com>
 <alpine.LRH.2.00.1006230857450.25778@tundra.namei.org> <4C224463.90306@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 23 Jun 2010, Chuck Lever wrote:

> > There are also several proprietary NFSv3 xattr implementations out there
> > across various OSs -- it would be useful to provide users of these an
> > open, maintained option, as well as a pathway to NFSv4.
> 
> Given that there are disparate proprietary NFSv3 xattr implementations how do
> you plan to ensure interoperability without a protocol specification or at
> least an RPCL definition?  Is interoperability even practical at this point?

I intend to publish a specification and RPCL once the basic direction of 
the implementation is worked out.

For the case of proprietary implementations, the primary aim would not be 
interop, but to provide an option migrate to an open, mainstream 
implementation.

Note that this implementation I've posted could be made to interop with 
the IRIX version without much trouble.  I'm guessing the use-case here 
would be legacy IRIX clients which could be migrated to a Linux server.  

There's also the possibility of interop with FreeBSD.

> 
> You say "it would be useful to provide users of these an open, maintained
> option" but so far, security labels appear to be the only specific use case
> you've mentioned.  What other interesting applications of xattrs would be
> useful to expose via NFS?

As I mentioned to Trond, I'm not sure.  There are desktop apps which use 
xattrs -- I guess the question is how important it is that they use xattrs 
over NFS rather than their existing workarounds.

I wonder if OSX may be able to make use of them, rather than dropping ._ 
files all over my Linux NFS server.

> But the salient point, I think, is that if NFSv4 supports security labels,
> then those who require this feature will upgrade, independent of the broader
> adoption rate of NFSv4.

Security labeling is a standard feature of some OSs now, with general 
applicability.  By "those who require", you're potentially talking about 
most Fedora, RHEL, CentOS, OEL etc. users.

There's a lot of NFSv3 deployed out there and I don't see what's gained by 
forcing those people to choose between having security features enabled 
and upgrading to NFSv4.

We also don't know how long it will take to get all of the Labeled NFS 
changes into NFSv4.  In addition to extending the NFSv4 protocol itself, 
changes are also required in the RPC layer.  I've cc'd Dave Quigley, who 
may have a better idea of when the LNFS changes might be seen in 
production.

> > There is effort underway for NFSv4 in this area, designed around the full
> > security requirements of networked MAC labeling (Labeled NFS).  This
> > is a far more comprehensive effort, and obviously does not provide a
> > solution for NFSv3 users.
> 
> Having a design document would allow wider public assessment of whether there
> will be transition issues for users between your proposed NFSv3 xattr protocol
> and the labeled NFS work.  Do you have a published analysis of how NFSv3 xattr
> users would transition to NFSv4 labeled NFS?

No, but I'd expect that there would be transparent migration from NFSv3 
xattr to LNFS "Guest Mode":

https://tools.ietf.org/id/draft-quigley-nfsv4-sec-label-requirements-02.txt

> > With this NFSv3 xattr code, we are able to provide useful partial support
> > for MAC security labeling, for the scenario where the server simply stores
> > security labels without interpreting them.  This allows clients to perform
> > fine-grained security labeling over NFSv3, and enforce policy locally.
> 
> Given that NFSv3 deployments overwhelmingly use AUTH_SYS authentication and do
> not use wire encryption, how do you guarantee that xattrs aren't modified
> during transit between server and client?

For NFSv3, this is not addressed by the XATTR protocol, it's only about 
label transport.  You could use stronger NFS security, or even IPSec, 
although MAC labeling is not enforced on the server, so you do not have a 
complete solution.

These issues are addressed by LNFS, and not really viable for NFSv3.

> > There is considerable demand for NFS security labeling from users.
> > 
> > They've been deploying MAC security in production for several years now
> > but have always had to limit what they do regarding NFS.  This would
> > provide a useful partial solution for these users via NFSv3, as an
> > intermediate step towards adopting NFSv4 and Labeled NFS.
> 
> To play devil's advocate for a moment, what's the practical difference between
> not having support for security labels now, and having it sometime in the near
> future with NFSv4?

People can deploy stronger security sooner.

> of my concerns.  And if the only purpose of your post was for review before
> including it in RH products, then you might ignore the following concerns.

The aim is to have this integrated upstream, for use by Fedora, RHEL, 
CentOS, Oracle Enterprise Linux, Smack, embedded/mobile distros, Ubuntu, 
Gentoo, OpenSUSE etc.

> However, since we're talking about more than a few lines of code and a rather
> limited lifetime of usefulness, I think that before upstream considers
> accepting this new side band protocol, there are larger issues than whether it
> works today between two Linux systems, and avoids crashing.
> 
>   o  Do we understand the use cases for xattr over NFSv3?
>   o  Do we understand the interoperability requirements?
>   o  Will NFSv3's known security issues prevent this from being ultimately
> useful?
>   o  Is the work to support this feature upstream worth the year or two it
> will be useful before NFSv4 labels are available?
>   o  Are there other near term solutions?
>   o  How do we ensure this implementation continues to meet its specified
> requirements over time (ie is there a protocol spec? how will implementations
> be tested)?

These would be good topics to cover in a specification.

> I think you should consider some next steps:
> 
>   o  Talk with other O/S and NFS server implementers who have xattrs to see if
> there are real interoperability concerns
>   o  Produce an RPCL and a design document
>   o  Find other compelling use cases for exposing xattrs to NFS clients
>   o  Tie into the labeled NFS work to see whether a Linux prototype on NFSv4
> at this time would be useful

Prototype LNFS code has existed for quite some time:
http://selinuxproject.org/page/Labeled_NFS

>   o  Consider proposing xattr support in NFSv4 to the NFSv4 working group
> 
> And if you want to consider some specific mechanical items:
> 
>   o  Use the page cache instead of the RPC buffer for storing xattrs during
> RPC operations
>   o  Get an RPC program number from IANA
> 

Agreed.

Ok, thanks for all the feedback.


- James
-- 
James Morris
<jmorris@namei.org>
