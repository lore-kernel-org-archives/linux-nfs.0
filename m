From: Sev Binello <sev@bnl.gov>
Subject: executables crash when moved
Date: Wed, 15 Feb 2006 12:58:46 -0500
Message-ID: <43F36BD6.7010408@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9QvW-0007UX-Mv
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 09:58:54 -0800
Received: from smtpgw.bnl.gov
	([130.199.3.132] helo=smtpgateway.bnl.gov ident=SMTP)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F9QvU-0004Eg-MG
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 09:58:54 -0800
Received: from acnlin64.pbn.bnl.gov ([130.199.104.22])
	by smtpgw.bnl.gov with esmtps (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(bnl.gov SMTP on gw3)
	serial 1F9QvO-00038g-AL
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 12:58:46 -0500
To: nfs@lists.sourceforge.net
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

We have had a consistent problem of executables shared over NFS crashing
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

    Has anyone experienced a similar problem,
     and come up with a solution ?

Thanks
-Sev

-- 

Sev Binello
Brookhaven National Laboratory
Upton, New York
631-344-5647
sev@bnl.gov



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
