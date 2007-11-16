From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: fail module init on reply cache init	failure
Date: Fri, 16 Nov 2007 10:30:36 -0500
Message-ID: <20071116153036.GG31958@fieldses.org>
References: <1195163823-24609-1-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-2-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-3-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-4-git-send-email-bfields@citi.umich.edu>
	<473DA941.4050101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <473DA941.4050101@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 16, 2007 at 09:29:21AM -0500, Peter Staubach wrote:
> J. Bruce Fields wrote:
>> +	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
>>   
>
> I was thinking that it might be nice to have something which
> better explains what the ramifications of this failure might
> be.  This explains _precisely_ what happened, but not what
> will happen in the future.

The module will fail to load (or, I suppose, the kernel will fail to
boot?).  So the failure will be pretty obvious.

>
> Or can we get this documented in some fashion that admins
> will know how to find and translate to what they need to
> understand and do?

Would a more explicit statement of the cause (like "nfsd: out of memory
setting up reply cache") be helpful?

Obviously this should only happen in a rather extreme low-memory
condition.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs
