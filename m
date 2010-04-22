From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS and /dev/mdXpY
Date: Thu, 22 Apr 2010 15:56:21 -0400
Message-ID: <1271966181.593.23.camel@localhost.localdomain>
References: <20100417195747.5fae8834.stealth@sourcemage.org>
	 <20100422182543.GB8858@fieldses.org>
	 <20100422225310.38e37038.stealth@sourcemage.org>
	 <20100422193236.GA10302@fieldses.org>
	 <1271965650.593.21.camel@localhost.localdomain>
	 <20100422235100.0616ce1d.stealth@sourcemage.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org
To: Vlad Glagolev <stealth@sourcemage.org>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20100422235100.0616ce1d.stealth@sourcemage.org>
Sender: linux-raid-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-04-22 at 23:51 +0400, Vlad Glagolev wrote: 
> On Thu, 22 Apr 2010 15:47:30 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > On Thu, 2010-04-22 at 15:32 -0400, J. Bruce Fields wrote: 
> > > On Thu, Apr 22, 2010 at 10:53:10PM +0400, Vlad Glagolev wrote:
> > > > On Thu, 22 Apr 2010 14:25:43 -0400
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > On Sat, Apr 17, 2010 at 07:57:47PM +0400, Vlad Glagolev wrote:
> > > > > > Well, hello there,
> > > > > > 
> > > > > > Posted it on linux-kernel ML also, and post it here, for more specific analysis.
> > > > > > 
> > > > > > I faced this problem today while trying to mount some NFS share on OpenBSD box.
> > > > > > I mounted it successfully without any visible errors, but I wasn't able to cd there, the printed error was:
> > > > > > 
> > > > > > ksh: cd: /storage - Stale NFS file handle
> > > > > > 
> > > > > > Apropos, the partition is 5.5 TB. I tried another one on my box and it was mounted successfully. It was possible to manage files there too. Its size is ~3GB.
> > > > > > That's why the first time I thought about some size limitations of OpenBSD/Linux/NFS.
> > > > > > 
> > > > > > While talking on #openbsd @ freenode, I discovered this via tcpdump on both sides:
> > > > > > 
> > > > > > http://pastebin.ca/1864713
> > > > > > 
> > > > > > Googling for 3 hours didn't help at all, some posts had similiar issue but either with no answer at all or without any full description.
> > > > > > 
> > > > > > Then I started to experiment with another Linux box to kill the possible different variants.
> > > > > > 
> > > > > > On another box I also have nfs-utils 1.1.6 and kernel 2.6.32. Mounting that big partition was unsuccessful, it got just stuck. On tcpdump I've seen this:
> > > > > 
> > > > > I'm a bit confused.  What kernel and nfs-utils version is running on the
> > > > > problematic Linux server?
> > > > 
> > > > same. nfs-utils 1.1.6 and kernel 2.6.32.
> > > 
> > > Huh.  That should be new enough for it to be using uuid's.  I wonder why
> > > it isn't?
> > 
> > What are the contents of /dev/disk/by-uuid?
> > 
> 
> $ ls -1 /dev/disk/by-uuid/
> 0e9742f6-44e3-431c-911f-4c914e4f81d5
> 31ae89c6-dba6-4351-b3a9-e8b08be07c3d
> 4429ba7a-afd2-4c61-83a0-900dae1bccdc
> 463bbc42-c19b-4b9e-bae7-838ac0e2e5c6
> 473b9320-88a4-44eb-b592-2ac98619bc9b
> 53d16b07-d496-4f8f-ad59-ea34aaf169f4
> 6adf1c55-405c-43cf-a84d-be5d2746d300
> b35a7bca-12ad-4738-a895-52f20b7cc5d9
> dc892f1f-0b83-41dd-bde7-0761295f33a3
> f7ac4165-320f-4235-a78a-5fe1bd0aac24
> 

So, when you do 'ls -l' on the above, you do indeed see all the
partitions that are being exported via NFS?

