From: Alan Powell <lakerfaniam2@yahoo.com>
Subject: Re: Re: nfsd tuning - please help me! (Alan Powell)
Date: Mon, 17 Feb 2003 17:38:18 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030218013818.44926.qmail@web12206.mail.yahoo.com>
References: <5CA6F03EF05E0046AC5594562398B916A3281B@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lakerfaniam2@yahoo.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web12206.mail.yahoo.com ([216.136.173.90])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18kwiB-0005gh-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 17:38:19 -0800
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>,
  nfs@lists.sourceforge.net
In-Reply-To: <5CA6F03EF05E0046AC5594562398B916A3281B@POEXMB3.conoco.net>
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

Yes indeed, the problem is probably that I have too
many files in each directory. Recommended # of
files/directory is a different topic, so I'll start a
new thread for that. Thanks!

(by the way, I did follow each and every suggestion in
the NFS Tuning How-To)


--- "Heflin, Roger A."
<Roger.A.Heflin@conocophillips.com> wrote:
> 
> 
> 
> >  Date: Fri, 14 Feb 2003 09:44:53 -0800 (PST)
> > From: Alan Powell <>
> > Subject: Re: [NFS] nfsd tuning - please help me!
> > To: Steve Dickson <SteveD@RedHat.com>,
> nfs@lists.sourceforge.net
> > 
> > Unfortunately, we've tried all that already. So
> given
> > that we are not hardware/network constrained, does
> all
> > this mean that the Linux kernel NFS runs into
> > performance issues beyond 100 file reads/sec?
> > 
> > 
> 	I have been able to get closer to 10-20MBytes per
> second with
> 	linux nfs.  The netapps will do around 4-5 times
> that though at
> 	a higher cost.  And you can get it out of linux, by
> putting more
> 	cheap smaller servers to obtain the same rate.
> 
> 	What are you underlying disks?  You could still be
> hardware
> 	constrained depending on what your underlying disks
> are,
> 	and what you underlying disk controller is.   Both
> can have
> 	issues.
> 
> 	I have machines that are servicing around 2500 8k
> reads
> 	per second and seem to work fine, though mine may
> break
> 	down to fewer larger reads.
> 
> 	Other things that will get you in trouble is having
> lots of files
> 	in a single directory (in the several thousand
> range will hurt
> 	pretty bad), also check to make sure you aren't
> accumulating lots
> 	of .nfs* files in the directies in question, I had
> a situation where
> 	there where lots of files being messed with (read
> and write) and
> 	lots of these files accumulated and pretty much
> brought
> 	performance to its knees.  The solution was to run
> a cron job
> 	to clean up the .nfs* files.  The .nfs files are
> created when you
> 	are reading a file that is being deleted by another
> process at
> 	the same time, the .nfs* stays around to service
> the reader,
> 	and does not always go away (this is on all NFS
> implementations
> 	I have seen).
> 
> 	Do a ls -ld dirname and see the size of the
> directories, and include it
> 	in the next message if one of the above don't pan
> out.
> 
> 							Roger
> 
> 					
> 
> 
>
-------------------------------------------------------
> This SF.NET email is sponsored by: FREE  SSL Guide
> from Thawte
> are you planning your Web Server Security? Click
> here to get a FREE
> Thawte SSL guide and find the answers to all your 
> SSL security issues.
>
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
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
