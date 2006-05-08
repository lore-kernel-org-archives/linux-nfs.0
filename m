From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH,RESEND] make knfsd interact cleanly with HSMs
Date: Mon, 8 May 2006 07:42:55 +0100
Message-ID: <20060508064255.GA8614@infradead.org>
References: <20060505115254.GA13916@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20060505115254.GA13916@sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

NACK.  As long as we have no HSM support in the tree there's no reason to
add this.  From the kernel's point it's just untested and unused code that
can break.

