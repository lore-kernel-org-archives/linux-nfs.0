From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
	protocol
Date: Thu, 8 Oct 2009 13:22:48 -0400
Message-ID: <20091008172248.GB24911@fieldses.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org> <bf63d7240910080919nf1bf6d0rd94f671d0645f674@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	linux-fsdevel@vger.kernel.org
To: Sriram Ramkrishna <sri@ramkrishna.me>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <bf63d7240910080919nf1bf6d0rd94f671d0645f674@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 08, 2009 at 09:19:13AM -0700, Sriram Ramkrishna wrote:
> On Sat, Sep 19, 2009 at 8:09 AM, James Morris <jmorris@namei.org> wrote:
> 
> >
> > Currently, the code is implemented only to support Linux namespace.name
> > xattrs in the "user" namespace.  It could be extended to support other
> > similar name/value pair xattr implementations (and not far from IRIX wire
> > compat), although that's not an aim of this version.  There may also be
> > some scope for limited support of system xattrs (e.g. 'dumb' security
> > label transport), although I've not looked beyond user.* so far.
> >
> >
> James this is great news.  I personally am interested (as a consumer) in
> setting up better ACL list (ala AFS) than the POSIX model we have now and
> trying to implement it using xattr might be the right way.

By the way, I'd be curious if you could summarize why POSIX ACLs (and
NFSv4 ACLs?) don't meet your requirements.

--b.

> But my
> frustration of course was that everybody did xattr in different ways and no
> filesystem implementer wanted to go on a limb and implemented such things
> without a RFC.
> 
> 
> >
> > Note that I'll be giving a talk on this at LinuxCon on Thursday:
> > http://linuxcon.linuxfoundation.org/meetings/1589 So, in addition to
> > discussion here, please come along to the talk if you're at the conf, and
> > we may also be able to discuss it at Plumbers in one of the BoFs.
> >
> 
> 
> Ah, I was there, and I was asking around wanting to talk about the issue!
> Ah well.
> 
> sri
