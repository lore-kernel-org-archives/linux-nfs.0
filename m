From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: executables crash when moved
Date: Wed, 15 Feb 2006 14:31:55 -0500
Message-ID: <1140031915.7888.35.camel@lade.trondhjem.org>
References: <43F36BD6.7010408@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9SNn-00019V-EQ
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 11:32:11 -0800
Received: from pat.uio.no ([129.240.130.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F9SNl-0006Ba-GA
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 11:32:11 -0800
To: Sev Binello <sev@bnl.gov>
In-Reply-To: <43F36BD6.7010408@bnl.gov>
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

On Wed, 2006-02-15 at 12:58 -0500, Sev Binello wrote:
> We have had a consistent problem of executables shared over NFS crashing
> when new executables are released.
> 
>     Before a new executable replaces an older one with a cp,
>     we mv the executable to a fallback dir and rename it.
>     We have 2 renaming schemes,
>     either .old, .older, .oldest or  append a date to the old executable.
>    
>     This used to work fine when the nfs sever was solaris,
>     however since we migrated it to redhat linux WS,
>     we find that the executables crash with a SIGBUS.
>    
>     The executables don't necessarily crash right away,
>     as a matter of fact we can't intentionally reproduce the crash.
>     Which leads me to believe it is cache related.

It isn't. It is a consequence of using the (admittedly _very_ stupid)
default server setting of "subtree_check", and then renaming into a
different directory (man 5 exports).

You have one of 2 possible solutions:

 1) Edit your /etc/exports, and add no_subtree_check options to the
entries for your exported filesystem.

OR

 2) rename the executables into the same directory.

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
