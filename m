From: Joe.Pranevich@lycos-inc.com
Subject: NFS performance "leak"  on 2.6.18?
Date: Fri, 31 Aug 2007 15:55:34 -0400
Message-ID: <OF47963A01.F14CACDA-ON85257348.006BD6E0-85257348.006D7305@lycos-inc.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0103844431=="
Cc: nfs@lists.sourceforge.net
To: trond@netapp.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRCah-0002yv-BN
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 12:55:39 -0700
Received: from usmail02.wal.lycos-inc.com ([209.67.227.152])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IRCal-0003aK-FL
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 12:55:43 -0700
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

This is a multipart message in MIME format.
--===============0103844431==
Content-Type: multipart/alternative;
	boundary="=_alternative 006D730385257348_="

This is a multipart message in MIME format.
--=_alternative 006D730385257348_=
Content-Type: text/plain; charset="US-ASCII"

Hello,

Trond, we spoke about a year back because I had an obscure problem with 
deadlocks which, as it turned out, was being tickled by (but not in) the 
NFS code. You helped to point me in the right direction and I managed to 
get everything happy. I hope that maybe you can point me in the right 
direction again.

I just upgraded one of our systems to RedHat AS/Centos 5 with their 
modified 2.6.18 kernel. I run Tripod.com/Angelfire.com, large free web 
providers all using Netapps/NFS behind our webservers. (There is a lot 
more architectural complexity than that, but that's the gist of it.) All 
NFSv3, of course. DataOnTap 7.x.

I have a script which, when I run it immediately after a reboot (or nearly 
immediately) it takes 4 minutes to run. It does tons of very small reads 
and writes all over the place across 12 different NFS mounts, etc. After a 
day, the script takes 20 minutes to run. After two days, the script takes 
40 minutes to run. (Approximately) Gradually, it takes longer and longer 
every day with no underlying change in load. (No processes stacking up, 
etc.) After a week or so of this, I have to reboot the entire farm and 
everything is fast again. While I use the example of this script, other 
NFS operations gradually seem to become slower. I can time "df" commands 
and see the same slowdown. Our web performance also times slower. 

Can you think of any known issues which I might be running into? I've 
sifted through your patches and will be adding them to my kernel, I'm 
recompiling something stock to make sure it's not a redhat addition, etc. 
But possibly you've seen this before and have a good recommendation?

Any ideas?

Thanks,

Joe Pranevich
Lycos Operations Manager
--=_alternative 006D730385257348_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2 face="sans-serif">Hello,</font>
<br>
<br><font size=2 face="sans-serif">Trond, we spoke about a year back because
I had an obscure problem with deadlocks which, as it turned out, was being
tickled by (but not in) the NFS code. You helped to point me in the right
direction and I managed to get everything happy. I hope that maybe you
can point me in the right direction again.</font>
<br>
<br><font size=2 face="sans-serif">I just upgraded one of our systems to
RedHat AS/Centos 5 with their modified 2.6.18 kernel. I run Tripod.com/Angelfire.com,
large free web providers all using Netapps/NFS behind our webservers. (There
is a lot more architectural complexity than that, but that's the gist of
it.) All NFSv3, of course. DataOnTap 7.x.</font>
<br>
<br><font size=2 face="sans-serif">I have a script which, when I run it
immediately after a reboot (or nearly immediately) it takes 4 minutes to
run. It does tons of very small reads and writes all over the place across
12 different NFS mounts, etc. After a day, the script takes 20 minutes
to run. After two days, the script takes 40 minutes to run. (Approximately)
Gradually, it takes longer and longer every day with no underlying change
in load. (No processes stacking up, etc.) After a week or so of this, I
have to reboot the entire farm and everything is fast again. While I use
the example of this script, other NFS operations gradually seem to become
slower. I can time &quot;df&quot; commands and see the same slowdown. Our
web performance also times slower. </font>
<br>
<br><font size=2 face="sans-serif">Can you think of any known issues which
I might be running into? I've sifted through your patches and will be adding
them to my kernel, I'm recompiling something stock to make sure it's not
a redhat addition, etc. But possibly you've seen this before and have a
good recommendation?</font>
<br>
<br><font size=2 face="sans-serif">Any ideas?</font>
<br>
<br><font size=2 face="sans-serif">Thanks,</font>
<br>
<br><font size=2 face="sans-serif">Joe Pranevich</font>
<br><font size=2 face="sans-serif">Lycos Operations Manager</font>
--=_alternative 006D730385257348_=--


--===============0103844431==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============0103844431==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0103844431==--
