Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hr2.samba.org ([144.76.82.148]:53029 "EHLO hr2.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978AbcEJIMv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 May 2016 04:12:51 -0400
Date: Tue, 10 May 2016 10:11:50 +0200
From: Jeremy Allison <jra@samba.org>
To: Volker Lendecke <Volker.Lendecke@SerNet.DE>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [PATCH v21 00/22] Richacls
Message-ID: <20160510081150.GA3411@jeremy-ThinkPad-T430s>
Reply-To: Jeremy Allison <jra@samba.org>
References: <1462831375-23017-1-git-send-email-agruenba@redhat.com>
 <20160510041809.GB1079@sernet.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160510041809.GB1079@sernet.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 10, 2016 at 06:18:10AM +0200, Volker Lendecke wrote:
> On Tue, May 10, 2016 at 12:02:33AM +0200, Andreas Gruenbacher wrote:
> > What more can I do to finally get this merged?
> 
> While I am not the one to comment on kernel specifics, from a pure Samba
> user space perspective let me say: We need this. NOW.

+1 from me. This is something that many vendors need
and have needed for a very long time. Getting this
in will allow *large* amounts of existing storage to
be migrated to Linux.
