From: "Steven N. Hirsch" <shirsch@adelphia.net>
Subject: Re: Re: broken umount -f
Date: Tue, 14 Jan 2003 17:29:29 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0301141728040.5354-100000@atx.fast.net>
References: <20030114221755.GB1042@questra.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,  <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [64.8.50.178] (helo=mta2.adelphia.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YZbN-0006jg-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 14:32:09 -0800
To: Scott Mcdermott <smcdermott@questra.com>
In-Reply-To: <20030114221755.GB1042@questra.com>
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

On Tue, 14 Jan 2003, Scott Mcdermott wrote:

> Trond Myklebust on Tue 14/01 20:35 +0100:
> >      > Last I checked, the programs wouldn't die even with -KILL when
> >      > they were stuck in device-wait state.
> > 
> > They will if you mount with 'intr', and make sure that you kill *all*
> > programs that are using that mountpoint.
> 
> I don't want users to be able to corrupt their own data by using `intr'
> when I am just bouncing the server for some reason.  But, I want root to
> be able to force it if necessary, as in the case of a client reboot when
> the server is gone (eg when switching servers and they need new handles
> for their automounts, but still have the old ones and the server is
> never coming back up).  Usually this means the admin screwed up, but
> unfortunately that does happen.
> 
> "umount -f" seems like the right place for this.

You have my vote.  For sanity's sake, there needs to be a big, red lever 
under the locked access hatch - labled "I said umount -f, dammit!".




-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
