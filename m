From: Kalin KOZHUHAROV <kalin@thinrope.net>
Subject: Re: rpc.statd: open (/var/lib/nfs/state): Permission denied
Date: Sat, 31 Dec 2005 14:51:52 +0900
Message-ID: <43B61C78.5000500@thinrope.net>
References: <43B514AC.7080400@thinrope.net> <20051231050049.GV29622@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EsZfS-0007SV-Qr
	for nfs@lists.sourceforge.net; Fri, 30 Dec 2005 21:52:38 -0800
Received: from s175249.ppp.asahi-net.or.jp ([220.157.175.249] helo=mail.tar.bz)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EsZfR-000392-Cg
	for nfs@lists.sourceforge.net; Fri, 30 Dec 2005 21:52:39 -0800
To: Garrick Staples <garrick@usc.edu>
In-Reply-To: <20051231050049.GV29622@polop.usc.edu>
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

Garrick Staples wrote:
> On Fri, Dec 30, 2005 at 08:06:20PM +0900, Kalin KOZHUHAROV alleged:
> 
>>celina nfs # ls -ld /var/lib/nfs/{,state}
>>drwxr-xr-x  7 root   root 304 Dec 30 18:42 /var/lib/nfs/
>>-rw-------  1 nobody root   6 Dec 30 18:50 /var/lib/nfs/state
> 
> 
> Have you checked the perms on /, /var, and /var/lib?
> 
Ooops :-)
Thank you for pointing that! Now, this was the situation:

celina ~ # ll -d / /var /var/lib
d-wxr----t  21 root root 568 Dec 22 21:05 /
drwxr-xr-x  21 root root 584 Dec 26 15:49 /var
drwxr-xr-x  12 root root 304 Dec 30 17:59 /var/lib

Ouch... Who the .uc. chmod-ed /? Knowing it is probably me does not make me feel better.
Found another box with the same problem, so might have to investigate it.

Anyway, fixind that and creating/chmod-ing /var/lib/nfs/sm{,.bak} and now everything is fine!

celina ~ # ls -ld / /var /var/lib /var/lib/nfs /var/lib/nfs/{state,sm*}
drwxr-xr-x  21 root   root 568 Dec 22 21:05 /
drwxr-xr-x  21 root   root 584 Dec 26 15:49 /var
drwxr-xr-x  12 root   root 304 Dec 31 14:38 /var/lib
drwxr-xr-x   7 root   root 304 Dec 31 14:41 /var/lib/nfs
drwxr-xr-x   2 nobody root  48 Dec 30 20:25 /var/lib/nfs/sm
drwxr-xr-x   2 nobody root  48 Dec 30 20:25 /var/lib/nfs/sm.bak
-rw-------   1 nobody root   4 Dec 31 14:41 /var/lib/nfs/state

Will have to drink less coffee, I guess :-)

Happy hollidays to all!

Kalin.
-- 
|[ ~~~~~~~~~~~~~~~~~~~~~~ ]|
+-> http://ThinRope.net/ <-+
|[ ______________________ ]|



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
