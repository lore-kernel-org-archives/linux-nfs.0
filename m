From: Alan Powell <lakerfaniam2@yahoo.com>
Subject: Re: nfsd tuning - please help me!
Date: Mon, 17 Feb 2003 18:28:40 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030218022840.96018.qmail@web12204.mail.yahoo.com>
References: <20030217025922.GA20685@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Powell <lakerfaniam2@yahoo.com>, Steve Dickson <SteveD@RedHat.com>,
  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web12204.mail.yahoo.com ([216.136.173.88])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18kxUu-0006pn-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 18:28:40 -0800
To: Yusuf Goolamabbas <yusufg@outblaze.com>, Ion Badulescu <ionut@badula.org>
In-Reply-To: <20030217025922.GA20685@outblaze.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Good idea. Note that we need to get the directory
indexing kernel patch applied (see separate thread I
started), or else bozos like me will blame NFS for
ext3's horrendous performance in dealing with
directories containing large numbers of files!

--- Yusuf Goolamabbas <yusufg@outblaze.com> wrote:
> Maybe RH can put their kernel's through a fstress
> routine
> 
> http://www.cs.duke.edu/ari/fstress/
> 
> According to the author Darell Anderson,
> 
>
http://docs.freebsd.org/cgi/getmsg.cgi?fetch=1126014+0+archive/2003/freebsd-current/20030216.freebsd-current
> 
> It can emulates SPECsfs
> 
> > > Unfortunately, we've tried all that already. So
> given
> > > that we are not hardware/network constrained,
> does all
> > > this mean that the Linux kernel NFS runs into
> > > performance issues beyond 100 file reads/sec?
> > 
> > It's quite possible...
> > 
> > What I'd recommend, however, is testing this again
> with a non-RedHat
> > kernel on the client. More precisely, try running
> 2.4.20 plus the 
> > NFSALL patch from Trond's site
> <http://www.fys.uio.no/~trondmy/src/>.
> > 
> > We've had significant performance problems over
> here with the RedHat
> > kernels, which mostly went away when we replaced
> the NFS client code
> > with 2.4.20+NFSALL.
> > 
> > Hope this helps,
> > Ion
> 
> 
>
-------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


__________________________________________________
Do you Yahoo!?
Yahoo! Shopping - Send Flowers for Valentine's Day
http://shopping.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
