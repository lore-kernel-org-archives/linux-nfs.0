From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Fri, 9 Oct 2009 11:31:55 +1100 (EST)
Message-ID: <alpine.LRH.2.00.0910091130440.32154@tundra.namei.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org> <bf63d7240910080919nf1bf6d0rd94f671d0645f674@mail.gmail.com> <20091008172123.GA24911@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sriram Ramkrishna <sri@ramkrishna.me>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	linux-fsdevel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20091008172123.GA24911@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 8 Oct 2009, J. Bruce Fields wrote:

> I assume that it was in order to avoid that question that this initial
> implementation only exports the user.* namespace, since xattr's in that
> name space are by design not given any special interpretation by the
> filesystem--they just store and return opaque data.

Correct -- there are no system semantics (beyond existing DACsecurity 
checks), so it's straightforward.

Other namespaces would need to have semantics defined on a case by case 
basis.


> 
> --b.
> 
> > 
> > 
> > >
> > > Note that I'll be giving a talk on this at LinuxCon on Thursday:
> > > http://linuxcon.linuxfoundation.org/meetings/1589 So, in addition to
> > > discussion here, please come along to the talk if you're at the conf, and
> > > we may also be able to discuss it at Plumbers in one of the BoFs.
> > >
> > 
> > 
> > Ah, I was there, and I was asking around wanting to talk about the issue!
> > Ah well.
> > 
> > sri
> 

-- 
James Morris
<jmorris@namei.org>
