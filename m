From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/14] locks: factor out generic/filesystem switch from test_lock
Date: Sun, 4 Feb 2007 08:41:10 +0000
Message-ID: <20070204084110.GB29531@infradead.org>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu> <5cdd83858bf5c75e14742bbd03b462f5ec4997fe.1170479265.git.bfields@citi.umich.edu> <20070203085025.GB18828@infradead.org> <20070204014844.GG7588@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070204014844.GG7588@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Feb 03, 2007 at 08:48:44PM -0500, J. Bruce Fields wrote:
> Actually, I wonder if there's any reason we couldn't also just give
> posix_test_lock() the same interface as ->lock?  (The latter uses the
> same file_lock argument for the input and (in the case where it finds
> a conflicting lock) the output, where the former uses an extra argument
> to pass back the lock.)  That'd make this a little simpler too.

yes, giving posix_test_lock the same interface as ->lock would be
even better. 

