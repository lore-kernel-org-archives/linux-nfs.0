From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Expected NFS behavior?
Date: Sat, 18 Feb 2006 00:24:09 -0500
Message-ID: <1140240250.7872.13.camel@lade.trondhjem.org>
References: <20060217214800.9612.qmail@web37415.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FAKa5-0004GK-Dz
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 21:24:29 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FAKa3-00042m-QE
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 21:24:29 -0800
To: Bill Johnstone <beejstone3@yahoo.com>
In-Reply-To: <20060217214800.9612.qmail@web37415.mail.mud.yahoo.com>
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

On Fri, 2006-02-17 at 13:48 -0800, Bill Johnstone wrote:
> Hello.
> 
> I've got a network wherein the machines are all running kernel 2.6.12,
> and NFSv3 is exclusively being used.  The exports / mounts are all
> 'sync'.  I'm seeing some behavior that doesn't seem to be correct to
> me, and I want to see if this is expected or if I'm hitting a bug or
> perhaps hardware failure/flakiness along the way.
> 
> The scenario:
> 
> A user has an existing set of files on the server, on an XFS volume.
> 
> If he is on the server (i.e. logged in via ssh) and runs a cp command
> to overwrite existing file "a" with file "b", then file "a" appears to
> be correctly overwritten as verified from the command-line on the
> server.  However, when any of the client machines opens file "a" after
> this, they see the previous contents.  It seems like an incoherent
> cache issue.
> 
> If the user instead runs the cp command on one of the client machines,
> then all the client machines now see the updated file.
> 
> Does this sound like it should be expected behavior, i.e. if the file
> changes "underneath" NFS (direct to the volume via command-line) will
> NFS have stale information, or should it explicitly handle this case?

Try a more recent client. There were a number of fixes that went into
2.6.14 and 2.6.15 to address cache consistency issues.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
