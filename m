From: Sev Binello <sev@bnl.gov>
Subject: Re: executables crash when moved
Date: Wed, 15 Feb 2006 16:29:53 -0500
Message-ID: <43F39D51.5010803@bnl.gov>
References: <43F36BD6.7010408@bnl.gov> <1140031915.7888.35.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/html; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9UDp-0005uJ-VH
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 13:30:01 -0800
Received: from smtpgw.bnl.gov
	([130.199.3.132] helo=smtpgateway.bnl.gov ident=SMTP)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F9UDo-0007D1-Gs
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 13:30:02 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140031915.7888.35.camel@lade.trondhjem.org>
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

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
Trond Myklebust wrote:
<blockquote cite="mid1140031915.7888.35.camel@lade.trondhjem.org"
 type="cite">
  <pre wrap="">On Wed, 2006-02-15 at 12:58 -0500, Sev Binello wrote:
  </pre>
  <blockquote type="cite">
    <pre wrap="">We have had a consistent problem of executables shared over NFS crashing
when new executables are released.

    Before a new executable replaces an older one with a cp,
    we mv the executable to a fallback dir and rename it.
    We have 2 renaming schemes,
    either .old, .older, .oldest or  append a date to the old executable.
   
    This used to work fine when the nfs sever was solaris,
    however since we migrated it to redhat linux WS,
    we find that the executables crash with a SIGBUS.
   
    The executables don't necessarily crash right away,
    as a matter of fact we can't intentionally reproduce the crash.
    Which leads me to believe it is cache related.
    </pre>
  </blockquote>
  <pre wrap=""><!---->
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

  </pre>
</blockquote>
Many, many .... many thanks !<br>
<br>
-Sev<br>
<br>
<pre class="moz-signature" cols="100">-- 

Sev Binello
Brookhaven National Laboratory
Upton, New York
631-344-5647
<a class="moz-txt-link-abbreviated" href="mailto:sev@bnl.gov">sev@bnl.gov</a>
</pre>
</body>
</html>


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
