From: David Howells <dhowells@redhat.com>
Subject: Curiosities of Linux NFSD file handles
Date: Thu, 04 Dec 2008 16:46:57 +0000
Message-ID: <19603.1228409217@redhat.com>
Cc: dhowells@redhat.com, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I've been poking around in the exportfs code, and I see that the handle decode
routines seem to expect that they may be given more data for a handle than the
encode_fh() routine produced.

Is this still true?  Or can I assume that the amount of data now given to the
decoder will exactly reflect the amount of data obtained from the encoder?

David
