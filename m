Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:43287
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751268Ab1JTJUH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2011 05:20:07 -0400
Date: Thu, 20 Oct 2011 05:19:46 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, agruen@kernel.org,
        akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
Message-ID: <20111020091946.GA23773@infradead.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20111019222021.GB1874@fieldses.org>
 <87k4805alx.fsf@linux.vnet.ibm.com>
 <20111020091434.GC5444@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111020091434.GC5444@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 05:14:34AM -0400, J. Bruce Fields wrote:
> > > Does it really make sense to use a string here just to pick between the
> > > three choices OWNER@, GROUP@, and EVERYONE@?  Why not just another small
> > > integer?  Is the goal to expand this somehow eventually?
> > 

> > I guess Andreas wanted the disk layout to be able to store user@domain
> > format if needed.
> 
> Is that likely?  For that to be useful, tasks would need to be able to
> run as user@domain strings.  And we'd probably want owners and groups to
> also be user@domain strings.
> 
> The container people seem to eventually want to add some kind of
> namespace identifier everywhere:
> 
> 	http://marc.info/?l=linux-kernel&m=131836778427871&w=2
> 
> in which case I guess we'd likely end up with (uid, user namespace id)
> instead of user@domain?


Storing strings is an extremly stupid idea.  The only thing that would
make sense would be storing a windows-style 128-bit GUID.

