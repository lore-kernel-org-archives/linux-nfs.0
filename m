From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 18/18] xstat: Provide a mechanism to gather extra results
 for [f]xstat() [ver #6]
Date: Sun, 18 Jul 2010 04:51:40 -0400
Message-ID: <20100718085140.GD27794@infradead.org>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
 <20100715021730.5544.68442.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
	linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
	linux-ext4@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-cifs-owner@vger.kernel.org>
In-Reply-To: <20100715021730.5544.68442.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-cifs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As mentioned before this is total overkill.  The request/respond flags
together with the buffer size already provide enough ways to extent
the structure in a backwards compatible way if needed.
