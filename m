Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35832 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772AbcCVUID (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2016 16:08:03 -0400
Date: Tue, 22 Mar 2016 16:08:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Richard Sharpe <realrichardsharpe@gmail.com>
Cc: Richard Yao <ryao@gentoo.org>, Cedric Blancher <cedric.blancher@gmail.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Steve French <smfrench@gmail.com>
Subject: Re: Making an interface for alternative data streams
Message-ID: <20160322200801.GF4083@fieldses.org>
References: <56F03945.40208@gentoo.org>
 <56F05745.50204@gentoo.org>
 <20160321204041.GA807@fieldses.org>
 <20160321223627.GA12999@thunk.org>
 <CALXu0UdPyhBpOb-q-jpVN55d5unAQYXQFSm7HgNKWBH0Q_-gmg@mail.gmail.com>
 <20160322001255.GA2353@fieldses.org>
 <009F3E87-7919-4774-9129-72DB08F76553@gentoo.org>
 <56F0AC2A.30300@gentoo.org>
 <CACyXjPyYK0CggZNGfQQj6BBAfahU7PmVzwpzfeUqBannUTdhqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CACyXjPyYK0CggZNGfQQj6BBAfahU7PmVzwpzfeUqBannUTdhqA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 22, 2016 at 09:15:44AM -0700, Richard Sharpe wrote:
> On Mon, Mar 21, 2016 at 7:21 PM, Richard Yao <ryao@gentoo.org> wrote:
> > On 03/21/2016 09:02 PM, Richard Yao wrote:
> >>
> >>> On Mar 21, 2016, at 8:12 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >>>
> >>>> On Mon, Mar 21, 2016 at 11:48:04PM +0100, Cedric Blancher wrote:
> >>>> Old invalid argument, and Sophos and Symatec look there as well.
> >>>>
> >>>> If it was a bad idea, why has Linux fs attributes which are almost the
> >>>> same as O_XATTR except that they use a custom api? Why does Macos have
> >>>> alternate streams (called forks)? Why did Solaris adopt it long ago
> >>>> (and still gets support questions about it - just saying before
> >>>> someone argues that no one uses THAT)?
> >>>
> >>> Could you point us at some of those users?
> >>
> >> I am told that Samba users would love this functionality.
> >
> > Someone pinged me in IRC to let me know that Steve French was talking
> > about this earlier this month:
> >
> >> Have there been any suggestions on how to list alternate data streams
> >> on a file other than using a pseudo-xattr as ntfs-3g does (querying
> >> xattr ntfs.streams.list - see http://linux.die.net/man/8/ntfs-3g)?
> >
> > http://permalink.gmane.org/gmane.linux.kernel.cifs/11681
> >
> > Windows appears to have name-value pair attributes and alternative data
> > streams in separate name-spaces simultaneously.
> 
> And it is more convoluted than that. If you use reparse points on a
> file you cannot use name-value pair attributes (Windows Extended
> Attributes) and vice versa, because they overloaded one of the fields
> use to report on those things.
> 
> Of course, pretty much no one uses Windows Extended Attributes these
> days, I believe.

But you do see people using "named attributes"/"alternative data
streams"?

This comes up at the LSF/MM summit every now and then and Jeremy Allison
inevitably says "hah, only malware writers use those", and that's the
end of the discussion.  Sounds like Richard Yao has heard otherwise, but
it'd be nice to have actual examples of users.

--b.

> 
> However, plenty of Samba users store Windows ACLs in Linux XATTRs ...
> 
> -- 
> Regards,
> Richard Sharpe
> (何以解憂？唯有杜康。--曹操)
