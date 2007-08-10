From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/4] Enable text-based NFS mounts, take two
Date: Sat, 11 Aug 2007 09:54:38 +1000
Message-ID: <18108.64190.983975.228309@notabene.brown>
References: <20070810221655.21712.54418.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJg66-0002Nt-NB
	for nfs@lists.sourceforge.net; Fri, 10 Aug 2007 18:48:58 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJg6A-0004NZ-Cu
	for nfs@lists.sourceforge.net; Fri, 10 Aug 2007 18:49:02 -0700
In-Reply-To: message from Chuck Lever on Friday August 10
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Friday August 10, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> Here are a couple of clean-ups, and two patches that provide a command
> line option on mount.nfs to force it to pass string mount options instead
> of binary mount options to the kernel.
> 
> I'd like to get these integrated into nfs-utils now in order to make it
> easy for people to start testing the kernel logic; and because Trond
> wants to freeze the mount ABI, so the only way to add new options is with
> a new string-based option.
> 
> The stropt.[ch] files are rather unfinished, but are in good enough shape
> that they can be used now and improved by everyone as we go along.  The
> command line option makes it so that normally mount.nfs will use the
> legacy binary options, and not accidentally pass text-based options; thus
> it is safe to install as a system's default /sbin/mount.nfs.
> 
> Today's version of these patches should address the concerns raised
> yesterday on this mailing list.

Thanks.  All applied.

I took the liberty of adding a test so that '-i' is only permitted for
root - just in case.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
