Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46536 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752481AbbH1V56 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Aug 2015 17:57:58 -0400
Date: Fri, 28 Aug 2015 17:57:58 -0400
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        LSM List <linux-security-module@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: Re: [RFC v6 03/40] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD
 permission flags
Message-ID: <20150828215758.GD23326@fieldses.org>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
 <1438689218-6921-4-git-send-email-agruenba@redhat.com>
 <CALCETrUoBnPyEGExpoDzHOCgnHh5=a1ROALmb63LLJZG+L=aQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALCETrUoBnPyEGExpoDzHOCgnHh5=a1ROALmb63LLJZG+L=aQA@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 28, 2015 at 02:36:15PM -0700, Andy Lutomirski wrote:
> On Tue, Aug 4, 2015 at 4:53 AM, Andreas Gruenbacher
> <andreas.gruenbacher@gmail.com> wrote:
> > Normally, deleting a file requires write and execute access to the parent
> > directory.  With Richacls, a process with MAY_DELETE_SELF access to a file
> > may delete the file even without write access to the parent directory.
> >
> > To support that, pass the MAY_DELETE_CHILD mask flag to inode_permission()
> > when checking for delete access inside a directory, and MAY_DELETE_SELF
> > when checking for delete access to a file itelf.
> >
> > The MAY_DELETE_SELF permission does not override the sticky directory
> > check.  It probably should.
> 
> Silly question from the peanut gallery: is there any such thing as
> opening an fd pointing at a file such that the "open file description"
> (i.e. the struct file) captures the right to delete the file?
> 
> IOW do we need FMODE_DELETE_SELF?

I guess FMODE_READ and _WRITE make sense because we pass file
descriptors to read() and write().  But we don't have a way to pass a
file descriptor to an operation that deletes a file.

(I think Windows may be different in both respects, it might be
interesting to compare, but I really don't understand how it works...).

--b.
