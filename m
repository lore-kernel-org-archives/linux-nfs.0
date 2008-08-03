From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Sun, 3 Aug 2008 13:15:19 -0400
Message-ID: <76bd70e30808031015l36db41bexf319e85ba7acc4e9@mail.gmail.com>
References: <18578.21997.529551.676627@notabene.brown>
	 <1217552437.3719.30.camel@shinybook.infradead.org>
	 <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
	 <1217597759.3454.356.camel@pmac.infradead.org>
	 <1217598976.3454.359.camel@pmac.infradead.org>
	 <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com>
	 <1217607571.3454.417.camel@pmac.infradead.org>
	 <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
	 <20080802182644.GE30454@fieldses.org>
	 <18581.40178.976747.769343@notabene.brown>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"David Woodhouse" <dwmw2@infradead.org>, viro@zeniv.linux.org.uk,
	"Christoph Hellwig" <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <18581.40178.976747.769343@notabene.brown>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 3, 2008 at 7:56 AM, Neil Brown <neilb@suse.de> wrote:
> On Saturday August 2, bfields@fieldses.org wrote:
>>
>> Though really I can't see any great objection to just moving xfs's hack
>> up into nfsd.  It may not do everything, but it seems like an
>> incremental improvement.
>
> Because it is a hack, and hacks have a tendency to hide deeper
> problems, and not be ever get cleaned up and generally to become a
> burden to future generations.

Agreed that maintainability is an important concern.

However, I don't see that what David suggests in general is hiding a
deeper problem, but is rather exposing it.  Can you explain what you
think is the issue?

> However if you do go down that path, can I suggest:
>
>  1/ get rid of the word "hack" throughout the code.  If you think it
>    is sensible, make it appear sensible.

Yes, if we're going to codify this method of handling readdir, let's
document it properly and treat it as a first class API.

>  2/ drop the "retry malloc of a smaller size" thing.
>    In fact, you can probably use one of the set of pages that has
>    been reserved for the request.  It is very rare that a readdir
>    request will be as big as the largest read.

Well, many Linux clients support reading directories only a page at a
time (this limitation may have been lifted recently).  But other
clients often ask to read much more.

Again it appears that a Linux NFS client is not going to be the real
acid test here.  Solaris and FreeBSD would probably be the best to
try, I think.

>  3/ Make the new way unconditional.  That gives it broader test
>    coverage which can only be a good thing.  And what is good for the
>    goose is good for the gander... (not that I'm calling anyone a
>    goose).

As Bruce also suggested, and I agree with this (not the goose part,
the unconditionality and test coverage parts).

-- 
 "Alright guard, begin the unnecessarily slow-moving dipping mechanism."
--Dr. Evil
