From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.20+NFS_ALL mount hanging, procs stuck in D state
Date: Fri, 17 Jan 2003 00:23:25 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15911.16109.364809.560776@charged.uio.no>
References: <shshec9p7zs.fsf@charged.uio.no>
	<Pine.LNX.4.40.0301160821590.2908-100000@bolt.sonic.net>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ZJMD-0000ok-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 15:23:33 -0800
To: Andrew Ryan <andrewr@nam-shub.com>
In-Reply-To: <Pine.LNX.4.40.0301160821590.2908-100000@bolt.sonic.net>
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

>>>>> " " == Andrew Ryan <andrewr@nam-shub.com> writes:

     > Not being a kernel developer, I do wonder why a single piece of
     > corrupted data can have the effect of hanging the mount for all
     > users and all processes. It also creates an unkillable process,
     > requiring the machine to be rebooted, relating to the 'unmount
     > -f' discussion that's been going on here lately.

That's the downside of TCP: it is supposed to be a continuous stream,
but it separated into 'segments' (RPC messages) of a length that is
specified within the stream itself. Get the length of one such segment
wrong, and you will be very unlikely to happen on the start of another
segment.

For the unkillable process, see the discussion about 'intr' and
earlier mails on the subject of unkillable NFS processes.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
