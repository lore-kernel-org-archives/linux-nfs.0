Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35765 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861Ab3BMVdy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2013 16:33:54 -0500
Date: Wed, 13 Feb 2013 16:33:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "sandeen@redhat.com" <sandeen@redhat.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        "gluster-devel@nongnu.org" <gluster-devel@nongnu.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: regressions due to 64-bit ext4 directory cookies
Message-ID: <20130213213346.GQ14195@fieldses.org>
References: <20130212202841.GC10267@fieldses.org>
 <20130213040003.GB2614@thunk.org>
 <20130213133131.GE14195@fieldses.org>
 <20130213151455.GB17431@thunk.org>
 <20130213151953.GJ14195@fieldses.org>
 <20130213153654.GC17431@thunk.org>
 <20130213162059.GL14195@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91F3D625D@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91F3D625D@sacexcmbx05-prd.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2013 at 04:43:05PM +0000, Myklebust, Trond wrote:
> On Wed, 2013-02-13 at 11:20 -0500, J. Bruce Fields wrote:
> > Oops, probably should have cc'd linux-nfs.
> > 
> > On Wed, Feb 13, 2013 at 10:36:54AM -0500, Theodore Ts'o wrote:
> > > The other thing that I'd note is that the readdir cookie has been
> > > 64-bit since NFSv3, which was released in June ***1995***.  And the
> > > explicit, stated purpose of making it be a 64-bit value (as stated in
> > > RFC 1813) was to reduce interoperability problems.  If that were the
> > > case, are you telling me that Sun (who has traditionally been pretty
> > > good worrying about interoperability concerns, and in fact employed
> > > the editors of RFC 1813) didn't get this right?  This seems
> > > quite.... surprising to me.
> > > 
> > > I thought this was the whole point of the various NFS interoperability
> > > testing done at Connectathon, for which Sun was a major sponsor?!?  No
> > > one noticed?!?
> > 
> > Beats me.  But it's not necessarily easy to replace clients running
> > legacy applications, so we're stuck working with the clients we have....
> > 
> > The linux client does remap the server-provided cookies to small
> > integers, I believe exactly because older applications had trouble with
> > servers returning "large" cookies.  So presumably ext4-exporting-Linux
> > servers aren't the first to do this.
> > 
> > I don't know which client versions are affected--Connectathon's next
> > week and I'll talk to people and make sure there's an ext4 export with
> > this turned on to test against.
> 
> Actually, one of the main reasons for the Linux client not exporting raw
> readdir cookies is because the glibc-2 folks in their infinite wisdom
> declared that telldir()/seekdir() use an off_t. They then went yet one
> further and decided to declare negative offsets to be illegal so that
> they could use the negative values internally in their syscall wrappers.
> 
> The POSIX definition has none of the above rubbish
> (http://pubs.opengroup.org/onlinepubs/009695399/functions/telldir.html)
> and so glibc brilliantly saddled Linux with a crippled readdir
> implementation that is _not_ POSIX compatible.
> 
> No, I'm not at all bitter...

Oh, right, I knew I'd forgotten part of the story....

But then you must have actually been testing against servers that were
using that 32nd bit?

I think ext4 actually only uses 31 bits even in the 32-bit case.  And
for a server that was literally using an offset inside a directory file,
that would be a colossal directory.

So I'm wondering how you ran across it.

Partly just pure curiosity.

--b.
