From: Brad Barnett <lists@L8R.net>
Subject: Re: knfsd brought to its knees, by a simple rsync or cp
 operation
Date: Tue, 1 Mar 2005 18:40:43 -0500
Message-ID: <20050301184043.4249a0db@be.back.l8r.net>
References: <20050226082854.2a496ec3@be.back.l8r.net>
	<20050228100633.GA4822@suse.de>
	<20050228102307.3788a184@be.back.l8r.net>
	<20050228154455.GS4822@suse.de>
	<20050228112018.34fdeb2b@be.back.l8r.net>
	<20050301095548.GJ14402@suse.de>
	<20050301065703.7e52cf4e@be.back.l8r.net>
	<20050301150446.GD4848@ti64.telemetry-investments.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: brugolsky@telemetry-investments.com
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6Gyp-0000rt-D1
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 15:40:43 -0800
Received: from l8r.net ([64.26.155.43] ident=aliens)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D6Gyo-0006OI-5b
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 15:40:43 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <20050301150446.GD4848@ti64.telemetry-investments.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>




Wow.

CBQ instantly resolved the issue.  After reading a bit more up on cbq, I
switched to deadline.

Deadline makes me happy. ;)

I am currently doing FIVE cp -al operations, as well as half a dozen ls -R
raid operations on the local box.  I see almost zero nfs slowdown. ;)

Thanks very much guys, for all your help.  I appreciate the effort
everyone put into this.  Hopefully this thread will help some people down
the road...

Thanks!


On Tue, 1 Mar 2005 10:04:46 -0500
"Bill Rugolsky Jr." <brugolsky@telemetry-investments.com> wrote:

> On Tue, Mar 01, 2005 at 06:57:03AM -0500, Brad Barnett wrote:
> > However, this is what is really erking me.  This isn't a heavy I/O
> > job. This is just _one_ cp.  Nothing else is happening on the entire
> > server!  I just did, in the above test:
> > 
> > client: ls -R /home
> > 
> > The client is fine, for very long periods of time...
> > 
> > Then, while the above command is still happening:
> > 
> > server: cp -a /raid/home /raid/hometest
> 
> You say that it isn't a heavy I/O job, but a recursive copy is a very
> seek-intensive one, particularly when copying a large tree to the same
> device, which will interleave reads and writes.  What filesystem are you
> using?  With an internal journal, journal writes will cause additional
> seeking.

ext3.  I do stress, however, that I find almost zero slowdown on the local
system, when I do a ls -R locally.  This is what set off my spidey sense.

>  
> > Within 10 seconds, the output of ls -R /home slows.  Within 20
> > seconds, it_stop_.  It then sits there for seconds, and spews out a
> > page in small jumps.  Again, a ls /raid/home on the _server_ barely
> > slows, and is constant.
> 
> Do you mean ls -R /raid/home here?  Is it definitely the case that
> ls -R /raid/home on the server is quick, but on the client it is slow?

Yes, most definitely ls -R /raid/home.  I've tested this dozens of times,
and it is as you say above.  Server fast, client slow.

> 
> How about ls -lR /raid/home on the server?  It could be that knfsd is
> returning file attribute information, hence reading the whole inode
> for each file, and not just for the directories.  getdents64() returns
> d_type=DT_DIR for directory entries, which allows ls -R to optimize the
> traversal so as to only call fstat64() on directories, not regular
> files. So on the server, ls -R would only fstat64() the entries, while
> on the client ls -R can cause knfsd to do the equivalent of ls -lR.
> 

ls -lR on the server is fast still.  There are no 5 second stalls... no
stalls at all, really.


> Also, which I/O scheduler are you using?

io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered
elevator: using anticipatory as default io scheduler

Should I try a different scheduler?  Deadline perhaps?


> 
> Regards,
> 
> 	Bill Rugolsky


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
