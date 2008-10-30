From: Jim Rees <rees@umich.edu>
Subject: Re: [patch 0/9] writeback data integrity and other fixes (take 3)
Date: Thu, 30 Oct 2008 09:41:18 -0400
Message-ID: <20081030134118.GA31598@citi.umich.edu>
References: <20081029031645.GE4985@disturbed> <20081029091203.GA32545@infradead.org> <20081029092143.GA5953@wotan.suse.de> <20081029094417.GA21824@infradead.org> <20081029103029.GC5953@wotan.suse.de> <20081029122234.GE846@shareable.org> <490865E3.8070102@gmail.com> <1225292196.6448.263.camel@think.oraclecorp.com> <20081030021601.GF18041@wotan.suse.de> <4909ADE0.1060205@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Piggin <npiggin@suse.de>,
	Chris Mason <chris.mason@oracle.com>,
	Ric Wheeler <ricwheeler@gmail.com>,
	Jamie Lokier <jamie@shareable.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org
To: jim owens <jowens@hp.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4909ADE0.1060205@hp.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

jim owens wrote:

  AFAIK the fsync semantic comes from the days of dinosaurs,
  mainframes, and minicomputers... when a lot of operating
  systems had user-space libraries that buffered the I/O.
  On fsync(fd), the "fd2" data would still be in user-space.

User space buffering happens in stdio, which is above the system call
level.  It's been that way since fsync() was first introduced, and is still
that way today.
