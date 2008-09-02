From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] UBIFS: fill f_fsid
Date: Tue, 2 Sep 2008 17:48:41 -0400
Message-ID: <20080902214841.GA9204@infradead.org>
References: <1220194366-12731-1-git-send-email-dedekind@infradead.org> <1220194366-12731-13-git-send-email-dedekind@infradead.org> <1220262187.2982.58.camel@pmac.infradead.org> <20080901150147.GA20323@infradead.org> <1220339032.4036.31.camel@sauron> <20080902170954.GE3086@webber.adilger.int> <20080902210219.GA9856@infradead.org> <1220390769.2985.6.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Andreas Dilger <adilger@sun.com>,
	Artem Bityutskiy <dedekind@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Adrian Hunter <ext-adrian.hunter@nokia.com>,
	linux-nfs@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1220390769.2985.6.camel@pmac.infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 02, 2008 at 10:26:09PM +0100, David Woodhouse wrote:
> > We also called the filesystem part of the NFS filehandle in a few
> > places, and for those it's correct that it should be stable.  Currently
> > the fsid is either created from the dev_t in kernelspace or from
> > uuids extracted through libuuid in userspace.
> 
> Or from the f_fsid returned in statfs(), as of a week or so ago.

I think that's a rather bad idea.  As mentioned before f_fsid is
basically random.

