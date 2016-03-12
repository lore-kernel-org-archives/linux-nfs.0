Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hr2.samba.org ([144.76.82.148]:34492 "EHLO hr2.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752185AbcCLVNL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Mar 2016 16:13:11 -0500
Message-ID: <1457817147.3540.28.camel@samba.org>
Subject: Re: [PATCH v18 00/22] Richacls (Core and Ext4)
From: Simo <simo@samba.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>
Date: Sat, 12 Mar 2016 16:12:27 -0500
In-Reply-To: <20160311140757.GB13178@fieldses.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
	 <20160311140134.GA14808@infradead.org>
	 <20160311140757.GB13178@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-03-11 at 09:07 -0500, J. Bruce Fields wrote:
> On Fri, Mar 11, 2016 at 06:01:34AM -0800, Christoph Hellwig wrote:
> > 
> > On Mon, Feb 29, 2016 at 09:17:05AM +0100, Andreas Gruenbacher
> > wrote:
> > > 
> > > Al,
> > > 
> > > could you please make sure you are happy with the current version
> > > of the
> > > richacl patch queue for the next merge window?
> > I'm still not happy.
> > 
> > For one I still see no reason to merge this broken ACL model at
> > all.
> > It provides our actualy Linux users no benefit at all, while
> > breaking
> > a lot of assumptions, especially by adding allow and deny ACE at
> > the
> > same sime.
> Could you explain what you mean by "adding allow and deny ACE at the
> same time"?
> 
> > 
> > It also doesn't help with the issue that the main thing it's trying
> > to be compatible with (Windows) actually uses a fundamentally
> > different
> > identifier to apply the ACLs to - as long as you're still limited
> > to users and groups and not guids we'll still have that mapping
> > problem
> > anyway.
> Agreed, but, one step at a time?  My impression is that the Samba
> people
> still consider this a step forward for Linux compatibility.

It is a step forward, but being able to store SIDs in the ACL, would be
a much better one.

Simo.

> --b.
> 
> > 
> > 
> > But besides that fundamental question on the purpose of it I also
> > don't think the code is suitable, more in the individual patches.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-cifs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

