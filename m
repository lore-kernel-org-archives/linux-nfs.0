From: Fengguang Wu <wfg-fOMaevN1BEbsJZF79Ady7g@public.gmane.org>
Subject: Re: read-ahead in NFS server
Date: Fri, 28 Dec 2007 10:33:21 +0800
Message-ID: <398809213.08803@ustc.edu.cn>
References: <c70ff3ad0712260351i6583aa8dpbf16ed606a634b1f@mail.gmail.com> <47730F2F.3080900@garzik.org> <c70ff3ad0712270050u134616d1q459ed073c586dcec@mail.gmail.com> <47739288.7000308@garzik.org> <c70ff3ad0712270700h6336b194r7c21834423aeb331@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	NFS list <linux-nfs@vger.kernel.org>
To: saeed bishara <saeed.bishara@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.ustc.edu.cn ([202.38.64.16]:41600 "HELO ustc.edu.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753708AbXL1Cd0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Dec 2007 21:33:26 -0500
In-Reply-To: <c70ff3ad0712270700h6336b194r7c21834423aeb331-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Message-Id: <E1J852H-0002K7-P1@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 27, 2007 at 05:00:12PM +0200, saeed bishara wrote:
> > >> Are you using TCP?  Are you using NFSv4, or an older version?
> > > I'm using NFSv3/UDP.
> >
> > IMO, you definitely want TCP and NFSv4.  Much better network behavior,
> > with some of the silly UDP limits (plus greatly improved caching
> > behavior, due to v4 delegations).
> the clients of my system going to be embedded system with low
> performance cpus and I need UDP as it needs less cpu power.

You can try the attached adaptive readahead patch.
Apply it on your server and compile kernel with CONFIG_ADAPTIVE_READAHEAD.
Use large 1MB readahead on server and small readahead on clients.

> > > when I run local dd with bs=4K, I can see that the average IO size is
> > > more than 300KB.
> >
> > Read-ahead is easier in NFSv4, because the client probably has the file
> > delegated locally, and has far less need to constantly revalidate file
> > mapping(s).
> I'll check that.
> but what about the server side? why the issued IO's are only as twice
> as the size of the NFS requests?

The readahead code is helpless in NFSv3 :-(
Use NFS over TCP and rsize=readahead=1MB on client side could help.
But if you prefer UDP, the above patch may help you :-)

Fengguang

