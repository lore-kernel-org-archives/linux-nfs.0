From: "Steven N. Hirsch" <shirsch@adelphia.net>
Subject: Re: Re: broken umount -f
Date: Tue, 14 Jan 2003 17:27:13 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0301141725240.5354-100000@atx.fast.net>
References: <15908.26262.547106.640066@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Scott Mcdermott <smcdermott@questra.com>,  <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [64.8.50.178] (helo=mta2.adelphia.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YZZC-0006RP-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 14:29:54 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15908.26262.547106.640066@charged.uio.no>
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

On Tue, 14 Jan 2003, Trond Myklebust wrote:

> >>>>> " " == Scott Mcdermott <smcdermott@questra.com> writes:
> 
>      > Last I checked, the programs wouldn't die even with -KILL when
>      > they were stuck in device-wait state.
> 
> They will if you mount with 'intr', and make sure that you kill *all*
> programs that are using that mountpoint.

I can honestly say that I end up rebooting more than 80% of the time when 
the server goes away.  Believe me, I've tried everything including taking 
the system down to single-user mode and killing everything not bolted to 
the kernel <g>.  

Steve




-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
