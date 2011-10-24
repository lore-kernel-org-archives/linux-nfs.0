Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e35.co.us.ibm.com ([32.97.110.153]:54402 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435Ab1JXLgk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2011 07:36:40 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 24 Oct 2011 05:36:40 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: agruen@kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V8 00/26]  New ACL format for better NFSv4 acl interoperability
In-Reply-To: <20111024094910.GA28693@infradead.org>
References: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20111024091716.GA1109@fieldses.org> <20111024094910.GA28693@infradead.org>
Date: Mon, 24 Oct 2011 17:05:28 +0530
Message-ID: <87fwiiei67.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 24 Oct 2011 05:49:10 -0400, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Oct 24, 2011 at 05:17:16AM -0400, J. Bruce Fields wrote:
> > > How do we push these changes to Linus tree ? Andrew, Viro, any comment
> > > on how we can get this merged upstream ?
> > 
> > Andrew, it sounds like you might be willing to shepherd these through?
> > Let us know what you'd need.
> 
> It really has to through the VFS tree.  And to be honest despite the
> repostings there's been exactly zero progress on getting there.
> 
> Please as a first thing submit the various small cleanups indepent
> of the other changes.  If you can't even those in there's no point
> in trying. 

I will do this as the next step. The series actually contain them as
separate patches.

> Second do not repeat the mistakes of the old ACL code,
> that is don't do too much work inside the filesystems.  Al, Linus
> and me spent a lot of working on pushing it into common code and
> it's not done.  For any new ACL model I really want to see zero
> per-fs code except for callouts in chmod & co and actually
> setting the xattr vector to a genericly provided one.  And please
> wire up all common filesystems to actually prove that point.
> 

This is what is done currently. I have only hooked up ext4 though.
What I have done is add a new inode operation get_richacl, that 
returns struct richacl *. Are you suggesting to get rid of that
and make sure get_acl can return different type of ACL based on
argument passed ?. IMHO that would end up making the code more complex.


> I also really hate all the duplication - I want to see a really good
> reason why all this code needs to be duplicated.  Just look at
> the mess done to check_acl and the ACL caching in the inode and
> any normal person would throw up.  There is absolutely no reason
> to not implement Posix ACLs as a subset of the NFSv4 ACL (not actually
> a subset in the strict mathematical sense, but close enough).
> 

Can you explain this more ? What you would like to see changed ?


> After all this techical work (which was brought up before) has been
> done you can resubmit it.  And that point you'd better have very
> good and very lengthy rationale for why adding an utterly stupid
> ACL model is supposed to be a good idea.

Thanks for the feedback.

-aneesh

