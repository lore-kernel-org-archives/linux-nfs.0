Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932450Ab2JYOeD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Oct 2012 10:34:03 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9PEY3tk021909
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2012 10:34:03 -0400
Date: Thu, 25 Oct 2012 10:34:01 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 10/10] nfsdcltrack: flip the default in autoconf to
 "yes" for it
Message-ID: <20121025103401.4b15123b@corrin.poochiereds.net>
In-Reply-To: <50894C88.9070205@RedHat.com>
References: <1351092359-25842-1-git-send-email-jlayton@redhat.com>
	<1351092359-25842-11-git-send-email-jlayton@redhat.com>
	<5089372D.1050501@RedHat.com>
	<20121025100707.4e01c0b7@corrin.poochiereds.net>
	<50894C88.9070205@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 25 Oct 2012 10:28:24 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 25/10/12 10:07, Jeff Layton wrote:
> > On Thu, 25 Oct 2012 08:57:17 -0400
> > Steve Dickson <SteveD@redhat.com> wrote:
> > 
> >>
> >>
> >> On 24/10/12 11:25, Jeff Layton wrote:
> >>> Allow nfsdcltrack to be built by default if all of the requirements
> >>> for it are in place. Set the initial state of $enable_nfsdcltrack
> >>> to "maybe", and fix the appropriate tests to just disable building
> >>> the binary unless someone explicitly requests it.
> >> Hmm... I'm not sure I too keen on this "maybe" state... 
> >>
> > 
> > Would it help if we renamed it to
> > "yes_but_only_if_requirements_are_met" ? :)
> :-) 
> 
> > 
> >> So if no flags are given to ./configuration, and not 
> >> all the requirements to build nfsdcltrack exists, the configuration 
> >> will succeed, but the command will not be build. Correct?
> >>
> > 
> > Correct.
> > 
> >> But if the  --enable_nfsdcltrack flag is given and not all
> >> the requirements to build nfsdcltrack exist the configuration
> >> will fail. 
> >>
> > 
> > Correct.
> > 
> >> I'm thinking we might want to make it a bit more binary. Either
> >> on or off. Like it is with the other conditionally built 
> >> commands... 
> >>
> > 
> > So you want to fail the configure stage if all of the requirements for
> > nfsdcltrack aren't present? That doesn't sound good to me. Note that we
> > do have "tristate" handling already for stuff like the --disable-uuid
> > option...
> I'm thinking there it might cause confusion to silently not build
> a binary, when the expectation is this should be there. I'm thinking
> a failure of the config script would remove that confusion... And
> as long as there a way to mask that failure out (aka --enable_nfsdcltrack=no
> or --disable_nfsdcltrack) it will make it more explicit to what is or
> is not happening... 
> 
>  

It's not silent. It does throw a warning in this case, but that is
likely to get lost in the noise. It's your call -- if you want to fail
the build by default if the requirements aren't present, then I'm ok
with that.

-- 
Jeff Layton <jlayton@redhat.com>
