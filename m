From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS BUG_ON in nfs_do_writepage
Date: Tue, 28 Apr 2009 07:59:38 -0400
Message-ID: <1240919978.7376.7.camel@heimdal.trondhjem.org>
References: <5da0588e0904131506k5c58e8ddob9bf38f61da6302a@mail.gmail.com>
	 <5da0588e0904131644g131dc816r61884e83bc4cd006@mail.gmail.com>
	 <5da0588e0904240226j3454941y5f58c17a32a9a23d@mail.gmail.com>
	 <1240671428.6112.1.camel@heimdal.trondhjem.org>
	 <20090426064026.GD28555@wotan.suse.de>
	 <1240755509.5055.34.camel@heimdal.trondhjem.org>
	 <20090426151324.GB5588@wotan.suse.de>
	 <1240768522.10548.33.camel@heimdal.trondhjem.org>
	 <20090428042717.GA6304@wotan.suse.de>
	 <1240919117.7376.6.camel@heimdal.trondhjem.org>
	 <20090428115449.GD9442@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org, Rince <rincebrain@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Nick Piggin <npiggin@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090428115449.GD9442@wotan.suse.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-04-28 at 13:54 +0200, Nick Piggin wrote:
> If the page gets cleaned after page_mkwrite and before the page
> table locks are taken again in order to set the pte writeable.
> (actually, page_mkclean only runs if it finds mapcount elevated,
> so it is enough to clean the page even after the locks are taken
> and before mapcount is incremented in the case of __do_fault).

OK. This was what I was missing...

Thanks!

