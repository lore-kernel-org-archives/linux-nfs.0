Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46362 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136Ab2CLQSe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 12:18:34 -0400
Date: Mon, 12 Mar 2012 11:49:21 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Ted Ts'o" <tytso@mit.edu>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120312154921.GB17153@pad.fieldses.org>
References: <20120109132158.2616029.30467.stgit@localhost.localdomain>
 <20120109132153.2616029.26302.stgit@localhost.localdomain>
 <20120306000837.GA17164@thunk.org>
 <20120306020819.GH31388@pad.fieldses.org>
 <20120306151816.GB32282@thunk.org>
 <20120306152842.GA8339@pad.fieldses.org>
 <20120309205148.GB5635@thunk.org>
 <20120312150912.GB12440@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120312150912.GB12440@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 12, 2012 at 11:09:12AM -0400, Ted Ts'o wrote:
> On Fri, Mar 09, 2012 at 03:51:48PM -0500, Ted Ts'o wrote:
> > 
> > Linus in general doesn't like cross tree merges (or any extraneous
> > merges) unless they are absolutely necessary; but then, he trusts git
> > merges more than many of us do.  :-)
> > 
> > I've put the the patch series on a separate patch, with a signed tag, at:
> > 
> >      git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git nfs-ext4-premerge
> > 
> > Can you confirm that you've pulled it into your tree and it's landed
> > in linux-next?  I probably won't bother pulling it in mine unless
> > there is definitely a merge conflict that I need to resolve.  (I've
> > checked and there do not appear to be any against linux-next as of
> > last night.)
> 
> Ping?

Whoops, sorry.

Looks perfect, thanks for handling these!

I'm running them through my usual regression tests and then I'll push
the result out soon, with a "here's why I'm merging this" comment on the
merge commit.  (Though I can't see it would trigger Linus's usual
back-merge rant anyway, as it's obviously quite targetted, not a case of
"oh I think I'll update to -rc5 now".)

--b.
