From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Mon, 7 Jul 2008 17:19:25 -0400
Message-ID: <20080707211925.GB19523@fieldses.org>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net> <20080703204543.GI30918@fieldses.org> <1215454820.19512.25.camel@localhost> <F84C7866-E340-49BF-B542-308E10AC9518@oracle.com> <1215456693.19512.36.camel@localhost> <76bd70e30807071244v4db1c366uc7599d2dd806bf1b@mail.gmail.com> <1215463877.19512.40.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59019 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755571AbYGGVT3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2008 17:19:29 -0400
In-Reply-To: <1215463877.19512.40.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 07, 2008 at 04:51:17PM -0400, Trond Myklebust wrote:
> On Mon, 2008-07-07 at 15:44 -0400, Chuck Lever wrote:
> 
> > If you would like connected UDP, I won't object to you implementing
> > it.  However, I never tested whether a connected UDP socket will give
> > the desired semantics without extra code in the UDP transport (for
> > example, an ->sk_error callback).  I don't think it's worth the hassle
> > if we have to add code to UDP that only this tiny use case would need.
> > 
> 
> OK. I'll set these patches aside until I have time to look into adding
> connected UDP support.

I'm curious--why weren't you convinced by this argument?:

	"You're talking about the difference between supporting say 1358
	mounts at boot time versus 1357 mounts at boot time.

	"In most cases, a client with hundreds of mounts will use up
	exactly one extra privileged TCP port to register NLM during the
	first lockd_up() call.  If these are all NFSv4 mounts, it will
	use exactly zero extra ports, since the NFSv4 callback service
	is not even registered.

	"Considering that _each_ mount operation can take between 2 and
	5 privileged ports, while registering NFSD and NLM both would
	take exactly two ports at boot time, I think that registration
	is wrong place to optimize."

I'll admit to not following this carefully, but that seemed reasonable
to me.

--b.
