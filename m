Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-annu.mail.uoguelph.ca ([131.104.91.36]:64095 "EHLO
	esa-annu.net.uoguelph.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752931Ab3CUOSP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 10:18:15 -0400
Date: Thu, 21 Mar 2013 10:15:47 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Christopher T Vogan <cvogan@us.ibm.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, nfsv4 list <nfsv4@ietf.org>,
        Tom Haynes <Tom.Haynes@netapp.com>
Message-ID: <721420190.6245.1363875347135.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <20130321133713.GB27838@fieldses.org>
Subject: Re: [nfsv4] What is NFSv4 READDIR doesn't return a filehandle....
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Mar 20, 2013 at 09:41:40PM -0400, Rick Macklem wrote:
> > Well, I don't see any difference between a mandatory attribute and a
> > recommended attribute that the server claims to support via the
> > supported_attributes attribute.
> >
> > I do believe that the server can choose not to return all of the
> > mandatory and supported recommended attributes in the readdir reply.
> > (If not, why have a bitmap of returned attributes?)
> >
> > One example here is the mounted_on_fileid, which some servers choose
> > to only "support" for server mount points. (The FreeBSD server
> > returns
> > this attribute for all file handles, setting it to the same value as
> > fileid for non-mount-points, but I am pretty sure some other servers
> > do not return mounted_on_fileid for non-mount-points.)
> 
> That doesn't sound like traditional unix readdir behavior, and isn't
> the
> behavior described by the spec; looking at 5661 5.8.2.23 (haven't
> compared other rfcs):
> 
> "If the server detects that there is no mounted point at the
> target file object, then the value for mounted_on_fileid that it
> returns is the same as that of the fileid attribute."
> 
> Also, the supported_attrs attribute is a filesystem-wide attribute. I
> don't think we generally allow attributes to vary between "supported"
> and "unsupported" on a single filesystem.
> 
> --b.
Well, I'm pretty sure some server did (maybe it has been changed more
recently) would only return mounted_on_fileid in the Readdir reply
if it was at a mount point.

I remember because it broke the FreeBSD client and I had to tweak
the code.

I'll try and remember to stick something in the FreeBSD client to
spot this for the next Bakeathon.

rick
