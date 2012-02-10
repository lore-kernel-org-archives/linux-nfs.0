Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60429 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759851Ab2BJSkP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 13:40:15 -0500
Date: Fri, 10 Feb 2012 13:40:12 -0500
To: steve <steve@steve-ss.com>
Cc: Don Riden <don@riden.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: where can I ask user qns about nfs4?
Message-ID: <20120210184012.GA5781@fieldses.org>
References: <4F2A2F9E.6030908@steve-ss.com>
 <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com>
 <4F2D9A0E.6010503@leicester.ac.uk>
 <4F2E4B50.5040701@steve-ss.com>
 <20120205141611.GA12826@umich.edu>
 <4F2EB471.9060508@leicester.ac.uk>
 <alpine.LNX.2.00.1202091707390.25543@localhost.localdomain>
 <4F341FA6.9080101@steve-ss.com>
 <4F34D31A.6050604@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F34D31A.6050604@steve-ss.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 10, 2012 at 09:19:38AM +0100, steve wrote:
> 
> >>
> >>I'm happy to provide more details of the domain joining process
> >>offlist or summarise in another
> >>email if there is interest.
> >>
> >>
> >>
> >>I'm surprised by the lack of documentation available on using
> >>Kerberised NFS with AD. I would have thought that it would be a
> >>fairly common configuration?
> >
> Hi
> This stuff really does need documenting. I've put together a rough
> guide of most of the common misunderstandings here:
> http://linuxcostablanca.blogspot.com/2012/02/nfsv4-myths-and-legends.html

Could you get some of this material into the linux-nfs wiki?

The NFS w/ AD stuff, for example, would probably be worth a page of its
own and a top-level link under "Documentation" (and the link to Mike
Eisler's blog entry could be moved to the page, if it still looks like
it's current).

--b.
