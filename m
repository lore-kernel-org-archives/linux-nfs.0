From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Curiosities of Linux NFSD file handles
Date: Thu, 4 Dec 2008 14:35:11 -0500
Message-ID: <20081204193511.GE7575@fieldses.org>
References: <19603.1228409217@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <19603.1228409217@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 04, 2008 at 04:46:57PM +0000, David Howells wrote:
> 
> I've been poking around in the exportfs code, and I see that the handle decode
> routines seem to expect that they may be given more data for a handle than the
> encode_fh() routine produced.

Somebody else who understands what you're asking about off the top of
their heads may be able to pop up and answer this.  But I'm a little
confused.  Which encode/decode routines exactly, and where do you see
them making assumptions about the size of the data?

--b.

> Is this still true?  Or can I assume that the amount of data now given to the
> decoder will exactly reflect the amount of data obtained from the encoder?
