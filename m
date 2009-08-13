From: Christoph Hellwig <hch@infradead.org>
Subject: Re: NFS and NFSv4 lists?
Date: Thu, 13 Aug 2009 14:14:50 -0400
Message-ID: <20090813181449.GA11931@infradead.org>
References: <20090813174923.GA15213@infradead.org>
	<1250186824.16167.31.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1250186824.16167.31.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 13, 2009 at 02:07:04PM -0400, Trond Myklebust wrote:
> On Thu, 2009-08-13 at 13:49 -0400, Christoph Hellwig wrote:
> > Is there really a reason to keep a separate NFSv4 mailing list?  v4
> > support is part of the same nfs/nfsd modules and quite deeply
> > interwinded with the v2/v3 code.  It seems most posts to the NFSv4 list
> > get cross-posted to the regular nfs list anyway.
> 
> I certainly agree that we can start deprecating the nfsv4@linux-nfs.org
> list, but I'm reluctant to shut it down completely as long as we're
> seeing some non-cross posted traffic there.
> 
> How about if we keep it open for another 6 months, and use that time to
> educate those people who post only on nfsv4@linux-nfs.org to move on to
> linux-nfs?

How about just turning the nfsv4 list into an auto-responder telling
people to use the linux-nfs@vger.kernel.org?
