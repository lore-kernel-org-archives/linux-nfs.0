From: "Yaniv Aknin" <yaniv@aknin.name>
Subject: Explanation of /proc/net/rpc/nfsd
Date: Thu, 21 Jun 2007 08:35:34 +0300
Message-ID: <ec3cf7fd0706202235v4f4ae95dw71061f55cd414644@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1044786588=="
To: nfs@lists.sourceforge.net, okir@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1FKQ-0003mf-O7
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 22:35:38 -0700
Received: from wa-out-1112.google.com ([209.85.146.179])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I1FKT-0000Pg-QU
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 22:35:38 -0700
Received: by wa-out-1112.google.com with SMTP id k22so186889waf
	for <nfs@lists.sourceforge.net>; Wed, 20 Jun 2007 22:35:35 -0700 (PDT)
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

--===============1044786588==
Content-Type: multipart/alternative;
	boundary="----=_Part_86064_9997803.1182404134823"

------=_Part_86064_9997803.1182404134823
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello Olaf, NFS list,

I've been searching for a while for a clear explanation of the fields in
/proc/net/rpc/nfsd, and yet was unable to find one. I hope I'm not doing a
big mess out of something which is clearly listed somewhere on the web
(ulp!).

Please find below my understanding of the file, as I derived from Googling
and nfs-utils' nfsstat.c. I'd appreciate it if you could please confirm the
following findings and elaborate on them a bit, following which I'll send
the consolidated information to the NFS HOWTO maintainer.

It's my understanding that rc, fh, io, ra, net and rpc counters are since
server reboot / nfs restart, or some such, and are monotonically rising.
Correct?

Finally, if some insight can be provided as to the meaning of each counters
(what should one do about a high number of stale fh's? What should one do
about too many uncached rc hits?) - that would probably be useful as well.

/* svcrcinfo - "server's request reply cache" */
/* <repcache hits> <repcache hits> <uncached reqs> */
rc 0 14690 304838843

/* svcfhinfo - "server's file handle cache" */
/* <stale> <FH lookups> <anon FHs> <non cached directories> <non cached
non-directories> */
fh 672 0 0 0 0

/* What's this? I didn't see it's parsed by nfsstat at all - no? */
io 1514602045 2448444

/* thread usage */
/* <number of threads> <??unknown??> number of seconds that top 10 leading
usage threads were at 100% usage> */
th 512 0 0.101 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000

/* Same here - what is it? I didn't see it's parsed at all...? */
ra 1024 247282073 3219961 2834659 2169015 1615489 1190804 790417 444564
205708 94686 1747233

/* svcnetinfo */
/* <# of received packets> <UDP packets> <TCP packets> <TCP connections> */
net 304858749 7690 304850968 18825

/* svcrpcinfo */
/* <total # of RPC calls> <total # of bad calls> <bad format>
<authentication failed> <unknown client> */
rpc 304856375 1927 1927 0 0

/* svcv2info */
/* I don't know, I think it lists the various NFSv2 calls - how many read,
write, readdir, ... */
/* I think it should be easy to read nfsstat.c more carefully and find the
correct names for each value, but if someone has it offhand - I'd appreciate
it */
proc2 18 1924 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

/* svcv3info */
/* I don't know, I think it lists the various NFSv3 calls - reads, writes,
readdirs, ... */
/* I think it should be easy to read nfsstat.c more carefully and find the
correct names for each value, but if someone has it offhand - I'd appreciate
it */
proc3 22 1983 10409344 1936 12940751 19882029 0 261590865 4930 2880 4942 0 0
2 0 0 0 0 17 4620 61 0 4811

svcv4info
/* I don't know, I think it lists the various NFSv4 calls - reads, writes,
readdirs, ...  -- but why so few calls?*/
proc4 2 1921 0

Many thanks,
 - Yaniv

------=_Part_86064_9997803.1182404134823
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello Olaf, NFS list,<br><br>I&#39;ve been searching for a while for a clear explanation of the fields in /proc/net/rpc/nfsd, and yet was unable to find one. I hope I&#39;m not doing a big mess out of something which is clearly listed somewhere on the web (ulp!).
<br><br>Please find below my understanding of the file, as I derived from Googling and nfs-utils&#39; nfsstat.c. I&#39;d appreciate it if you could please confirm the following findings and elaborate on them a bit, following which I&#39;ll send the consolidated information to the NFS HOWTO maintainer.
<br><br>It&#39;s my understanding that rc, fh, io, ra, net and rpc counters are since server reboot / nfs restart, or some such, and are monotonically rising. Correct?<br><br>Finally, if some insight can be provided as to the meaning of each counters (what should one do about a high number of stale fh&#39;s? What should one do about too many uncached rc hits?) - that would probably be useful as well.
<br><br>/* svcrcinfo - &quot;server&#39;s request reply cache&quot; */<br>/* &lt;repcache hits&gt; &lt;repcache hits&gt; &lt;uncached reqs&gt; */<br>rc 0 14690 304838843<br><br>/* svcfhinfo - &quot;server&#39;s file handle cache&quot; */
<br>/* &lt;stale&gt; &lt;FH lookups&gt; &lt;anon FHs&gt; &lt;non cached directories&gt; &lt;non cached non-directories&gt; */<br>fh 672 0 0 0 0<br><br>/* What&#39;s this? I didn&#39;t see it&#39;s parsed by nfsstat at all - no? */
<br>io 1514602045 2448444<br><br>/* thread usage */<br>/* &lt;number of threads&gt; &lt;??unknown??&gt; number of seconds that top 10 leading usage threads were at 100% usage&gt; */<br>th 512 0 0.101 0.000 0.000 0.000 0.000
 0.000 0.000 0.000 0.000 0.000<br><br>/* Same here - what is it? I didn&#39;t see it&#39;s parsed at all...? */<br>ra 1024 247282073 3219961 2834659 2169015 1615489 1190804 790417 444564 205708 94686 1747233<br><br>/* svcnetinfo */
<br>/* &lt;# of received packets&gt; &lt;UDP packets&gt; &lt;TCP packets&gt; &lt;TCP connections&gt; */<br>net 304858749 7690 304850968 18825<br><br>/* svcrpcinfo */<br>/* &lt;total # of RPC calls&gt; &lt;total # of bad calls&gt; &lt;bad format&gt; &lt;authentication failed&gt; &lt;unknown client&gt; */
<br>rpc 304856375 1927 1927 0 0<br><br>/* svcv2info */<br>/* I don&#39;t know, I think it lists the various NFSv2 calls - how many read, write, readdir, ... */<br>/* I think it should be easy to read nfsstat.c more carefully and find the correct names for each value, but if someone has it offhand - I&#39;d appreciate it */
<br>proc2 18 1924 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0<br><br>/* svcv3info */<br>/* I don&#39;t know, I think it lists the various NFSv3 calls - reads, writes, readdirs, ... */<br>/* I think it should be easy to read nfsstat.c
 more carefully and find
the correct names for each value, but if someone has it offhand - I&#39;d
appreciate it */<br>proc3 22 1983 10409344 1936 12940751 19882029 0 261590865 4930 2880 4942 0 0 2 0 0 0 0 17 4620 61 0 4811<br><br>svcv4info<br>/* I don&#39;t know, I think it lists the various NFSv4 calls - reads, writes, readdirs, ...&nbsp; -- but why so few calls?*/
<br>proc4 2 1921 0<br><br>Many thanks,<br>&nbsp;- Yaniv<br>

------=_Part_86064_9997803.1182404134823--


--===============1044786588==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1044786588==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1044786588==--
