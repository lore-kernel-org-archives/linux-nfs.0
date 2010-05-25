Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:58692 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757004Ab0EYOXG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 10:23:06 -0400
Date: Tue, 25 May 2010 16:07:42 +0200
From: Zdenek Salvet <salvet@ics.muni.cz>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Lukas Hejtmanek <xhejtman@ics.muni.cz>, Pavel Machek <pavel@ucw.cz>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, salvet@ics.muni.cz
Subject: Re: Deadlock in NFSv4 in all kernels
Message-ID: <20100525140742.GM12852@horn.ics.muni.cz>
Reply-To: salvet@ics.muni.cz
References: <20100507153920.GP28167@ics.muni.cz> <20100524212422.GA1286@ucw.cz> <1274790520.2949.20.camel@heimdal.trondhjem.org> <20100525125833.GB9731@ics.muni.cz> <1274794765.5377.43.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1274794765.5377.43.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 25, 2010 at 09:39:25AM -0400, Trond Myklebust wrote:
> The schemes I'm talking about typically had special memory pools
> preallocated for use by daemons, and would label the daemons using some
> equivalent of the PF_MEMALLOC flag to prevent recursion into the
> filesystem.

Yes. In my opinion, proper solution has to be careful at three points:
- daemons must be carefully written not to require much memory
- daemons should 'inherit' PF_MEMALLOC while processing upcalls 
- FS should try to flush fast enough (what W. Adamson wrote) and 
  delay new allocations when it cannot 

Regards,

Zdenek Salvet                                              salvet@ics.muni.cz 
Institute of Computer Science of Masaryk University, Brno, Czech Republic
and CESNET, z.s.p.o., Prague, Czech Republic
Phone: ++420-549 49 6534                           Fax: ++420-541 212 747
----------------------------------------------------------------------------
      Teamwork is essential -- it allows you to blame someone else.

