Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46112 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756329Ab3CUNhR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 09:37:17 -0400
Date: Thu, 21 Mar 2013 09:37:13 -0400
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Christopher T Vogan <cvogan@us.ibm.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, nfsv4 list <nfsv4@ietf.org>,
        Tom Haynes <Tom.Haynes@netapp.com>
Subject: Re: [nfsv4] What is NFSv4 READDIR doesn't return a filehandle....
Message-ID: <20130321133713.GB27838@fieldses.org>
References: <1363826022.4790.89.camel@leira.trondhjem.org>
 <1533754809.4129999.1363830100661.JavaMail.root@erie.cs.uoguelph.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1533754809.4129999.1363830100661.JavaMail.root@erie.cs.uoguelph.ca>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 20, 2013 at 09:41:40PM -0400, Rick Macklem wrote:
> Well, I don't see any difference between a mandatory attribute and a
> recommended attribute that the server claims to support via the
> supported_attributes attribute.
> 
> I do believe that the server can choose not to return all of the
> mandatory and supported recommended attributes in the readdir reply.
> (If not, why have a bitmap of returned attributes?)
> 
> One example here is the mounted_on_fileid, which some servers choose
> to only "support" for server mount points. (The FreeBSD server returns
> this attribute for all file handles, setting it to the same value as
> fileid for non-mount-points, but I am pretty sure some other servers
> do not return mounted_on_fileid for non-mount-points.)

That doesn't sound like traditional unix readdir behavior, and isn't the
behavior described by the spec; looking at 5661 5.8.2.23 (haven't
compared other rfcs):

	"If the server detects that there is no mounted point at the
	target file object, then the value for mounted_on_fileid that it
	returns is the same as that of the fileid attribute."

Also, the supported_attrs attribute is a filesystem-wide attribute.  I
don't think we generally allow attributes to vary between "supported"
and "unsupported" on a single filesystem.

--b.
