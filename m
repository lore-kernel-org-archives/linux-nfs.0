From: "NeilBrown" <neilb@suse.de>
Subject: Re: Curiosities of Linux NFSD file handles
Date: Fri, 5 Dec 2008 09:28:50 +1100 (EST)
Message-ID: <76726f87d17b81a0c8f1f773c1566b22.squirrel@neil.brown.name>
References: <19603.1228409217@redhat.com>
    <20081204193511.GE7575@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David Howells" <dhowells@redhat.com>,
	"Christoph Hellwig" <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20081204193511.GE7575@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, December 5, 2008 6:35 am, J. Bruce Fields wrote:
> On Thu, Dec 04, 2008 at 04:46:57PM +0000, David Howells wrote:
>>
>> I've been poking around in the exportfs code, and I see that the handle
>> decode
>> routines seem to expect that they may be given more data for a handle
>> than the
>> encode_fh() routine produced.
>
> Somebody else who understands what you're asking about off the top of
> their heads may be able to pop up and answer this.  But I'm a little
> confused.  Which encode/decode routines exactly, and where do you see
> them making assumptions about the size of the data?
>

I'm with Bruce here - what exactly do you mean?

The decode routine cannot assume anything about the filehandle
as it was received from the network and so is inherently untrustworthy.
However if it finds anything that it did not expect (i.e. that
encode could not have generated) then it is free to return an error.

NeilBrown

