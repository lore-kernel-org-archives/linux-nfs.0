From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Thu, 31 Jul 2008 20:53:26 -0400
Message-ID: <76bd70e30807311753m2785c6d3kd82edd1fe8b5f8b7@mail.gmail.com>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <20080501204820.GA5951@infradead.org>
	 <1209681898.25560.613.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
	 <1217541264.1126.15.camel@shinybook.infradead.org>
	 <18578.21997.529551.676627@notabene.brown>
	 <1217551230.3719.15.camel@shinybook.infradead.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Neil Brown" <neilb@suse.de>,
	"Christoph Hellwig" <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1217551230.3719.15.camel@shinybook.infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 31, 2008 at 8:40 PM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Fri, 2008-08-01 at 10:16 +1000, Neil Brown wrote:
>> On Thursday July 31, dwmw2@infradead.org wrote:
>> > On Fri, 2008-05-02 at 11:38 +1000, Neil Brown wrote:
>> > > Why is there a deadlock here?
>>
>> I was really hoping you would answer this question.
>
> It's because the nfsd readdirplus code recurses into the file system.
> >From the file system's ->readdir() function we call back into nfsd's
> encode_entry(), which then calls back into the file system's ->lookup()
> function so that it can generate a filehandle.
>
> For any file system which has its own internal locking -- which includes
> jffs2, btrfs, xfs, jfs, gfs*, ocfs* and probably others -- that
> recursive call back into the file system will deadlock.
>
> In the specific case of JFFS2, we need that internal locking because of
> lock ordering constraints with the garbage collection -- we need to take
> the allocator lock _before_ the per-inode lock, which means we can't use
> the generic inode->i_mutex for that purpose. That's documented in
> fs/jffs2/README.Locking. I know fewer details about the other affected
> file systems.
>
>> I can see the sense in your approach, but it does still seem a bit
>> hackish.  I would like to understand the details of the problem enough
>> to be confident that there is no less-hackish solution.
>
> I was thinking that we could perhaps get away with an extension to
> readdir() that passes the filehandle to its filldir callback too. I'm
> not sure if that's sufficient for NFS4 though.

For now it is sufficient, IMO.  NFSv4 doesn't implement a readdirplus
operation, and the performance benefits of NFSv3 readdirplus are
equivocal -- there isn't a strong desire to replicate the complexity
of NFSv3 readdirplus in NFSv4.  I'm not even sure you can do it even
with a single compound RPC, so even in the long run NFSv4 may not ever
have the locking issues that NFSv3 does here.

I agree with Neil, though -- as a reviewer, I think the architecture
of your solution is valid, but would need to audit these pretty
closely to get a sense of the individual correctness/appropriateness
of each change.

-- 
 "Alright guard, begin the unnecessarily slow-moving dipping mechanism."
--Dr. Evil
