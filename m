Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:59407 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752943AbcEJQEa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 May 2016 12:04:30 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Jeremy Allison'" <jra@samba.org>,
        "'Volker Lendecke'" <Volker.Lendecke@SerNet.DE>
Cc: "'Andreas Gruenbacher'" <agruenba@redhat.com>,
        "'Alexander Viro'" <viro@zeniv.linux.org.uk>,
        "'Christoph Hellwig'" <hch@infradead.org>,
        "'Theodore Ts'o'" <tytso@mit.edu>,
        "'Andreas Dilger'" <adilger.kernel@dilger.ca>,
        "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Jeff Layton'" <jlayton@poochiereds.net>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>,
        "'Anna Schumaker'" <anna.schumaker@netapp.com>,
        "'Dave Chinner'" <david@fromorbit.com>, <linux-ext4@vger.kernel.org>,
        <xfs@oss.sgi.com>, <linux-kernel@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <linux-cifs@vger.kernel.org>, <linux-api@vger.kernel.org>
References: <1462831375-23017-1-git-send-email-agruenba@redhat.com> <20160510041809.GB1079@sernet.de> <20160510081150.GA3411@jeremy-ThinkPad-T430s>
In-Reply-To: <20160510081150.GA3411@jeremy-ThinkPad-T430s>
Subject: RE: [PATCH v21 00/22] Richacls
Date: Tue, 10 May 2016 08:55:19 -0700
Message-ID: <002001d1aad4$5c3bd9f0$14b38dd0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Tue, May 10, 2016 at 06:18:10AM +0200, Volker Lendecke wrote:
> > On Tue, May 10, 2016 at 12:02:33AM +0200, Andreas Gruenbacher wrote:
> > > What more can I do to finally get this merged?
> >
> > While I am not the one to comment on kernel specifics, from a pure
> > Samba user space perspective let me say: We need this. NOW.
> 
> +1 from me. This is something that many vendors need
> and have needed for a very long time. Getting this in will allow *large*
> amounts of existing storage to be migrated to Linux.

+1 from me also. Once this is in Ganesha will integrate with it also.

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

