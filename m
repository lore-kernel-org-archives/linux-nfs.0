From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: NFS regression?  Odd delays and lockups accessing an NFS
 export.
Date: Tue, 12 May 2009 19:05:46 -0500
Message-ID: <20090512190546.5e8a7faf@osprey.hogchain.net>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	<20080818185048.GO20684@miggy.org>
	<48A9CF89.9090304@bellsouth.net>
	<1242160078.2404.6.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>, neilb@suse.de,
	bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757683AbZEMAGA@vger.kernel.org>
In-Reply-To: <1242160078.2404.6.camel@dyn9047022153>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 May 2009 13:27:58 -0700
Frank Filz <ffilzlnx@us.ibm.com> wrote:

> On Mon, 2008-08-18 at 14:37 -0500, J. K. Cliburn wrote:
> > Athanasius wrote:
> > > On Mon, Aug 18, 2008 at 12:02:20PM +1000, Grant Coady wrote:
> > >> I've been using NFS here for years, lately there's something odd going on 
> > >> since about a month or so.  Previously reported last month:
> > >> http://www.gossamer-threads.com/lists/linux/kernel/951419?page=last
[...]
> > I see you're running the atl1 driver on your client.  I'm chasing an 
> > intermittent bug in that driver that seems to be affected by certain 
> > offload parameters.  Try disabling TSO and see if things improve.
> 
> Was this ever resolved? We're seeing a similar hangup in a 2.6.27
> kernel.

The TSO problem in the atl1 driver was never resolved, and TSO was turned off by default with commit 82c26a9d117f0178b8c1b33429014b6d99c470f6 in the 2.6.27 cycle.  It was also added to the -stable tree at 2.6.26.4.

http://lkml.org/lkml/2008/9/3/251

Jay
