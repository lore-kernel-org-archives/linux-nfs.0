Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hr2.samba.org ([144.76.82.148]:52533 "EHLO hr2.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbcCVVnF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2016 17:43:05 -0400
Date: Tue, 22 Mar 2016 14:42:55 -0700
From: Jeremy Allison <jra@samba.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Richard Sharpe <realrichardsharpe@gmail.com>,
        Richard Yao <ryao@gentoo.org>,
        Cedric Blancher <cedric.blancher@gmail.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Steve French <smfrench@gmail.com>
Subject: Re: Making an interface for alternative data streams
Message-ID: <20160322214255.GA10921@jra3>
Reply-To: Jeremy Allison <jra@samba.org>
References: <56F03945.40208@gentoo.org>
 <56F05745.50204@gentoo.org>
 <20160321204041.GA807@fieldses.org>
 <20160321223627.GA12999@thunk.org>
 <CALXu0UdPyhBpOb-q-jpVN55d5unAQYXQFSm7HgNKWBH0Q_-gmg@mail.gmail.com>
 <20160322001255.GA2353@fieldses.org>
 <009F3E87-7919-4774-9129-72DB08F76553@gentoo.org>
 <56F0AC2A.30300@gentoo.org>
 <CACyXjPyYK0CggZNGfQQj6BBAfahU7PmVzwpzfeUqBannUTdhqA@mail.gmail.com>
 <20160322200801.GF4083@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160322200801.GF4083@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 22, 2016 at 04:08:01PM -0400, J. Bruce Fields wrote:
> 
> But you do see people using "named attributes"/"alternative data
> streams"?
> 
> This comes up at the LSF/MM summit every now and then and Jeremy Allison
> inevitably says "hah, only malware writers use those", and that's the
> end of the discussion.  Sounds like Richard Yao has heard otherwise, but
> it'd be nice to have actual examples of users.

The only use I know of other than malware writers is
the :Zone.Identifier stream used by Internet Explorer.

http://woshub.com/how-windows-determines-that-the-file-has-been-downloaded-from-the-internet/

Not sure if the new Microsoft browser still uses them
(I haven't used desktop Windows in over 10 years).
