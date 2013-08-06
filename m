Return-Path: linux-nfs-owner@vger.kernel.org
Received: from pfw.demon.co.uk ([62.49.22.168]:56569 "EHLO pfw.demon.co.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754767Ab3HFLCN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Aug 2013 07:02:13 -0400
Date: Tue, 6 Aug 2013 11:02:09 +0000
From: Larry Keegan <lk@pfw.demon.co.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, <linux-nfs@vger.kernel.org>
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130806110209.56e554a7@cs3.al.itld>
In-Reply-To: <20130726232111.2567a941@cs3.al.itld>
References: <20130725134515.67af44e2@cs3.al.itld>
	<20130725101143.6a22cb81@corrin.poochiereds.net>
	<20130725170526.6e54c7db@cs3.al.itld>
	<20130726145937.GB30651@fieldses.org>
	<20130726232111.2567a941@cs3.al.itld>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 26 Jul 2013 23:21:11 +0000
Larry Keegan <lk@pfw.demon.co.uk> wrote:
> On Fri, 26 Jul 2013 10:59:37 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Thu, Jul 25, 2013 at 05:05:26PM +0000, Larry Keegan wrote:
> > > On Thu, 25 Jul 2013 10:11:43 -0400
> > > Jeff Layton <jlayton@redhat.com> wrote:
> > > > On Thu, 25 Jul 2013 13:45:15 +0000
> > > > Larry Keegan <lk@pfw.demon.co.uk> wrote:
> > > > 
> > > > > Dear Chaps,
> > > > > 
> > > > > I am experiencing some inexplicable NFS behaviour which I
> > > > > would like to run past you.
> > > > > 
> > > > > I have a linux NFS server running kernel 3.10.2 and some
> > > > > clients running the same. The server is actually a pair of
> > > > > identical machines serving up a small number of ext4
> > > > > filesystems atop drbd. They don't do much apart from serve
> > > > > home directories and deliver mail into them. These have
> > > > > worked just fine for aeons.
> > > > > 
> > > > > The problem I am seeing is that for the past month or so, on
> > > > > and off, one NFS client starts reporting stale NFS file
> > > > > handles on some part of the directory tree exported by the
> > > > > NFS server. During the outage the other parts of the same
> > > > > export remain unaffected. Then, some ten minutes to an hour
> > > > > later they're back to normal. Access to the affected
> > > > > sub-directories remains possible from the server (both
> > > > > directly and via nfs) and from other clients. There do not
> > > > > appear to be any errors on the underlying ext4 filesystems.
> > > > > 
> > > > > Each NFS client seems to get the heebie-jeebies over some
> > > > > directory or other pretty much independently. The problem
> > > > > affects all of the filesystems exported by the NFS server, but
> > > > > clearly I notice it first in home directories, and in
> > > > > particular in my dot subdirectories for things like my mail
> > > > > client and browser. I'd say something's up the spout about 20%
> > > > > of the time.
> > 
> > And the problem affects just that one directory?
> 
> Yes. It's almost always .claws-mail/tagsdb. Sometimes
> it's .claws-mail/mailmboxcache and sometimes it's (what you would
> call) .mozilla. I suspect this is because very little else is being
> actively changed.
> 
> >  Ohter files and
> > directories on the same filesystem continue to be accessible?
> 
> Spot on. Furthermore, whilst one client is returning ESTALE the others
> are able to see and modify those same files as if there were no
> problems at all.
> 
> After however long it takes the client which was getting ESTALE on
> those directories is back to normal. The client sees the latest
> version of the files if those files have been changed by another
> client in the meantime. IOW if I hadn't been there when the ESTALE
> had happened, I'd never have noticed.
> 
> However, if another client (or the server itself with its client hat
> on) starts to experience ESTALE on some directories or others, their
> errors can start and end completely independently. So, for instance I
> might have /home/larry/this/that inaccessible on one NFS client,
> /home/larry/the/other inaccessible on another NFS client, and
> and /home/mary/quite/contrary on another NFS client. Each one bobs up
> and down with no apparent timing relationship with the others.
> 
> > > > > The server and clients are using nfs4, although for a while I
> > > > > tried nfs3 without any appreciable difference. I do not have
> > > > > CONFIG_FSCACHE set.
> > > > > 
> > > > > I wonder if anyone could tell me if they have ever come across
> > > > > this before, or what debugging settings might help me diagnose
> > > > > the problem?
> > > > Were these machines running older kernels before this started
> > > > happening? What kernel did you upgrade from if so?
> > > The full story is this:
> > > 
> > > I had a pair of boxes running kernel 3.4.3 with the aforementioned
> > > drbd pacemaker malarkey and some clients running the same.
> > > 
> > > Then I upgraded the machines by moving from plain old dos
> > > partitions to gpt. This necessitated a complete reload of
> > > everything, but there were no software changes. I can be sure that
> > > nothing else was changed because I build my entire operating
> > > system in one ginormous makefile.
> > > 
> > > Rapidly afterwards I switched the motherboards for ones with more
> > > PCI slots. There were no software changes except those relating to
> > > MAC addresses.
> > > 
> > > Next I moved from 100Mbit to gigabit hubs. Then the problems
> > > started.
> > 
> > So both the "good" and "bad" behavior were seen with the same 3.4.3
> > kernel?
> 
> Yes. I'm now running 3.10.2, but yes, 3.10.1, 3.10, 3.4.4 and 3.4.3
> all exhibit the same behaviour. I was running 3.10.2 when I made the
> network captures I spoke of.
> 
> However, when I first noticed the problem with kernel 3.4.3 it
> affected several filesystems and I thought the machines needed to be
> rebooted, but since then I've been toughing it out. I don't suppose
> the character of the problem has changed at all, but my experience of
> it has, if that makes sense.
> 
> > > Anyway, to cut a long story short, this problem seemed to me to
> > > be a file server problem so I replaced network cards, swapped
> > > hubs,
> > 
> > Including reverting back to your original configuration with 100Mbit
> > hubs?
> 
> No, guilty as charged. I haven't swapped back the /original/
> hubs, and I haven't reconstructed the old hardware arrangement exactly
> (it's a little difficult because those parts are now in use
> elsewhere), but I've done what I considered to be equivalent tests.
> I'll do some more swapping and see if I can shake something out.
> 
> Thank you for your suggestions.

Dear Chaps,

I've spent the last few days doing a variety of tests and I'm convinced
now that my hardware changes have nothing to do with the problem, and
that it only occurs when I'm using NFS 4. As it stands all my boxes are
running 3.10.3, have NFS 4 enabled in kernel but all NFS mounts are
performed with -o nfsvers=3. Everything is stable.

When I claimed earlier that I still had problems despite using NFS 3,
I think that one of the computers was still using NFS 4 unbeknownst to
me. I'm sorry for spouting guff.

Part of my testing involved using bonnie++. I was more than interested
to note that with NFS 3 performance can be truly abysmal if an NFS export
has the sync option set and then a client mounts it with -o sync. This
is a typical example of my tests:

client# bonnie++ -s 8g -m async
Writing with putc()...done
Writing intelligently...done
Rewriting...done
Reading with getc()...done
Reading intelligently...done
start 'em...done...done...done...
Create files in sequential order...done.
Stat files in sequential order...done.
Delete files in sequential order...done.
Create files in random order...done.
Stat files in random order...done.
Delete files in random order...done.
Version 1.03e       ------Sequential Output------ --Sequential Input- --Random-
                    -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
async            8G 53912  85 76221  16 37415   9 42827  75 101754   5 201.6  0
                    ------Sequential Create------ --------Random Create--------
                    -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
                 16  9006  47 +++++ +++ 13676  40  8410  44 +++++ +++ 14587  39
async,8G,53912,85,76221,16,37415,9,42827,75,101754,5,201.6,0,16,9006,47,+++++,+++,13676,40,8410,44,+++++,+++,14587,39

client# bonnie++ -s 8g -m sync
Writing with putc()...done
Writing intelligently...done
Rewriting...done
Reading with getc()...done
Reading intelligently...done
start 'em...done...done...done...
Create files in sequential order...done.
Stat files in sequential order...done.
Delete files in sequential order...done.
Create files in random order...done.
Stat files in random order...done.
Delete files in random order...done.
Version 1.03e       ------Sequential Output------ --Sequential Input- --Random-
                    -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
sync             8G 16288  29  3816   0  4358   1 55449  98 113439   6 344.2  1
                    ------Sequential Create------ --------Random Create--------
                    -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
                 16   922   4 29133  12  1809   4   918   4  2066   5  1907   4
sync,8G,16288,29,3816,0,4358,1,55449,98,113439,6,344.2,1,16,922,4,29133,12,1809,4,918,4,2066,5,1907,4

The above tests were conducted on the same client machine, having
4x2.5GHz CPU and 4GB of RAM, and against a server with 2x2.5GHz CPU
and 4GB of RAM. I'm using gigabit networking and have 0% packet loss.
The network is otherwise practically silent.

The underlying ext4 filesystem on the server, despite being encrypted
at the block device and mounted with -o barrier=1, yielded these
figures by way of comparison:

server# bonnie++ -s 8G -m raw
Writing with putc()...done
Writing intelligently...done
Rewriting...done
Reading with getc()...done
Reading intelligently...done
start 'em...done...done...done...
Create files in sequential order...done.
Stat files in sequential order...done.
Delete files in sequential order...done.
Create files in random order...done.
Stat files in random order...done.
Delete files in random order...done.
Version 1.03e       ------Sequential Output------ --Sequential Input- --Random-
                    -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
raw              8G 66873  98 140602  17 46965   7 38474  75 102117  10 227.7 0
                    ------Sequential Create------ --------Random Create--------
                    -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
                 16 +++++ +++ +++++ +++ +++++ +++ +++++ +++ +++++ +++ +++++ +++
raw,8G,66873,98,140602,17,46965,7,38474,75,102117,10,227.7,0,16,+++++,+++,+++++,+++,+++++,+++,+++++,+++,+++++,+++,+++++,+++

These figures seem reasonable for a single SATA HDD in concert
with dmcrypt. Whilst I expected some degradation from exporting and
mounting sync, I have to say that I'm truly flabbergasted by the
difference between the sync and async figures. I can't help but
think I am still suffering from some sort of configuration
problem. Do the numbers from the NFS client seem unreasonable?

Yours,

Larry.
