From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH 0/18] export operations rewrite
Date: Wed, 28 Mar 2007 17:39:34 +0100
Message-ID: <20070328163934.GA9100@infradead.org>
References: <20070317010946.GA24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070317010946.GA24947@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Mar 17, 2007 at 01:09:46AM +0000, Christoph Hellwig wrote:
> This patchset is a medium scale rewrite of the export operations
> interface.  The goal is to make the interface less complex, and
> easier to understand from the filesystem side, aswell as preparing
> generic support for exporting of 64bit inode numbers.

Any comments on this?  So far I got two positive responses in private
but no comment at all in public..
