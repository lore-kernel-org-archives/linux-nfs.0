From: Abhishek Rai <abbashake007@yahoo.com>
Subject: RE: regarding size limit of local client cache
Date: Tue, 11 Mar 2003 10:30:42 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030311183042.87762.qmail@web11405.mail.yahoo.com>
References: <6440EA1A6AA1D5118C6900902745938E07D5538B@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-368474160-1047407442=:86536"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web11405.mail.yahoo.com ([216.136.131.235])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18soWQ-0005Ym-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 10:30:42 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D5538B@black.eng.netapp.com>
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

--0-368474160-1047407442=:86536
Content-Type: text/plain; charset=us-ascii


hi, 
my client RAM size is 128 MB. No special mount options => default values set. i  performed this test with _NO_ other extra programs running(apart from linux regulars). This is one important information i missed out:- Each client reads all its required pages sequentially, and only after a minimum period of 40 seconds do I allow another client to start with its own reading exercises. So by the time a client comes around again and looks for its cached data it is at least 80 seconds since it was read. 

Also, there isn't a question of attribute cache invalidation (causing the client to purge its cache etc) because the original files on the server are not modified by anyone(no nfs client or even server applications). <<So is it more a question of the nfs client managing a "cumulative" cache space for all the current mounts having this machine as the client?>>. In this scenario howz the observed 8192 pages limit explained and how hard/flexible this limit is depending on general load on the client machine.

thanks


 "Lever, Charles" <Charles.Lever@netapp.com> wrote: hi-

you didn't tell us how large your client's RAM is,
what your mount options are, what other programs
are running on the clients, nor how long each client
takes to read (attribute cache invalidation might
cause each client to purge its cache, for instance).

as far as i know there is no 8192 page limit in the
NFS client.



-----Original Message-----
From: Abhishek Rai [mailto:abbashake007@yahoo.com] 
Sent: Tuesday, March 11, 2003 2:33 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] regarding size limit of local client cache


hi, 
this query arises from some small experiments i performed with my linux
nfs client (2.4.18). 
Conclusions first:- There is a limit of 8192 pages on the size of the
local client cache and this space is shared between the various nfs
mounts currently operating on this machine with this machine as the
client.
Question 1. I haven't been able to trace this 8192 pages limit to any
data structure or functionality - so please help
Question 2 : This question is regarding the management of this shared
cache, space freeing mechanism in the cache to make space for fresh
reads etc and arises from the following observations :-
I conducted the following experiments:- 'n' nfs clients (numbered 1, 2,
3) are currently mounted, reading 3 different non-overlapping directory
trees of some server. The events proceed as follows when n=2,
client 1 reads 4096 4k pages from the server. Then, client 2 reads 4096
4k pages(different from those read by 1) from the server.
client 1 again reads 4096 pages from the server followed by client 2
repeating the same. Except for the first read whent the cache is cold,
no later reads translate into an on-the-wire read.
<< just to add: i concluded of the 8192 pages limit from the following 3
observations: (1). when i made the two clients read 8192 pages each
alternatively, every read all through caused an on-the-wire-lookup, (2).
when only one client was repeatedly reading 8192 pages, the cache
completely satisfied all but the first request, (3). when only one
client was repeatedly reading 16384 pages, every read translated into an
on-the-wire read.>>
Now i made n=3. (no. of pages being read by each client continue to be
4096)
I tried out two different orderings of client reads - <1,2,3,1,2,3> and
<1,2,3,2,1>
In both these cases, __ALL__ reads translate into an on-the-wire read. I
expected some requirement based freeing of space in the client cache to
make space for say 3 after 1 and 2 have done their reads eg. if global
lru based freeing then in <123123>, 3 would cause 1's 4096 pages to be
thrown out of the cache to make space for its own 4096. And after that
in the next cycle, 1 would cause the same to 2... which would mean all
reads=on-the-wire-read. But this scenario would imply that in <12321>,
the second time 2 is around it would find its data still in the cache,
only 1 will suffer etc but this wasn't found to be the case. So when
space is needed - the space freeing protocol recklessly frees all
possible space ? no- global lru based freeing mechanism ? at least let
me know where lies the corresponding code. thanks a lot.
Question 3: server->nr_requests is limited by the hard limit
MAX_REQUEST_HARD. what is this server->nr_requests ? outstanding
unsatisfied requests ? Again where is the limit for cache size ?
Thanks in advance
cheers
Abhishek




Do you Yahoo!?
Yahoo! Web Hosting - establish your business online


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open!
Get cracking and register here for some mind boggling fun and
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist - NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


---------------------------------
Do you Yahoo!?
Yahoo! Web Hosting - establish your business online
--0-368474160-1047407442=:86536
Content-Type: text/html; charset=us-ascii

<P>hi, 
<P>my client RAM size is 128 MB. No special mount options =&gt; default values set. i&nbsp; performed this test with _NO_ other extra programs running(apart from linux regulars). This is one important information i missed out:- Each client reads all its required pages sequentially, and only after a minimum period of 40 seconds do I allow another client to start with its own reading exercises. So by the time a client comes around again and looks for its cached data it is at least 80 seconds since it was read. </P>
<P>Also, there isn't a question of attribute cache invalidation (causing the client to purge its cache etc)&nbsp;because the original files on the server are not modified by anyone(no nfs client or even server applications). &lt;&lt;So is it more a question of the nfs client managing a "cumulative" cache space for all the current mounts having this machine as the client?&gt;&gt;. In this scenario howz the observed 8192 pages limit explained and how hard/flexible this limit is depending on general load on the client machine.</P>
<P>thanks<BR></P>
<P>&nbsp;<B><I>"Lever, Charles" &lt;Charles.Lever@netapp.com&gt;</I></B> wrote: 
<BLOCKQUOTE style="PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #1010ff 2px solid">hi-<BR><BR>you didn't tell us how large your client's RAM is,<BR>what your mount options are, what other programs<BR>are running on the clients, nor how long each client<BR>takes to read (attribute cache invalidation might<BR>cause each client to purge its cache, for instance).<BR><BR>as far as i know there is no 8192 page limit in the<BR>NFS client.<BR><BR><BR><BR>-----Original Message-----<BR>From: Abhishek Rai [mailto:abbashake007@yahoo.com] <BR>Sent: Tuesday, March 11, 2003 2:33 AM<BR>To: nfs@lists.sourceforge.net<BR>Subject: [NFS] regarding size limit of local client cache<BR><BR><BR>hi, <BR>this query arises from some small experiments i performed with my linux<BR>nfs client (2.4.18). <BR>Conclusions first:- There is a limit of 8192 pages on the size of the<BR>local client cache and this space is shared between the various nfs<BR>mounts currently operating on this machine with this m
 achine as the<BR>client.<BR>Question 1. I haven't been able to trace this 8192 pages limit to any<BR>data structure or functionality - so please help<BR>Question 2 : This question is regarding the management of this shared<BR>cache, space freeing mechanism in the cache to make space for fresh<BR>reads etc and arises from the following observations :-<BR>I conducted the following experiments:- 'n' nfs clients (numbered 1, 2,<BR>3) are currently mounted, reading 3 different non-overlapping directory<BR>trees of some server. The events proceed as follows when n=2,<BR>client 1 reads 4096 4k pages from the server. Then, client 2 reads 4096<BR>4k pages(different from those read by 1) from the server.<BR>client 1 again reads 4096 pages from the server followed by client 2<BR>repeating the same. Except for the first read whent the cache is cold,<BR>no later reads translate into an on-the-wire read.<BR>&lt;&lt; just to add: i concluded of the 8192 pages limit from the following 3<BR
 >observations: (1). when i made the two clients read 8192 pages each<BR>alternatively, every read all through caused an on-the-wire-lookup, (2).<BR>when only one client was repeatedly reading 8192 pages, the cache<BR>completely satisfied all but the first request, (3). when only one<BR>client was repeatedly reading 16384 pages, every read translated into an<BR>on-the-wire read.&gt;&gt;<BR>Now i made n=3. (no. of pages being read by each client continue to be<BR>4096)<BR>I tried out two different orderings of client reads - &lt;1,2,3,1,2,3&gt; and<BR>&lt;1,2,3,2,1&gt;<BR>In both these cases, __ALL__ reads translate into an on-the-wire read. I<BR>expected some requirement based freeing of space in the client cache to<BR>make space for say 3 after 1 and 2 have done their reads eg. if global<BR>lru based freeing then in &lt;123123&gt;, 3 would cause 1's 4096 pages to be<BR>thrown out of the cache to make space for its own 4096. And after that<BR>in the next cycle, 1 would cause
  the same to 2... which would mean all<BR>reads=on-the-wire-read. But this scenario would imply that in &lt;12321&gt;,<BR>the second time 2 is around it would find its data still in the cache,<BR>only 1 will suffer etc but this wasn't found to be the case. So when<BR>space is needed - the space freeing protocol recklessly frees all<BR>possible space ? no- global lru based freeing mechanism ? at least let<BR>me know where lies the corresponding code. thanks a lot.<BR>Question 3: server-&gt;nr_requests is limited by the hard limit<BR>MAX_REQUEST_HARD. what is this server-&gt;nr_requests ? outstanding<BR>unsatisfied requests ? Again where is the limit for cache size ?<BR>Thanks in advance<BR>cheers<BR>Abhishek<BR><BR><BR><BR><BR>Do you Yahoo!?<BR>Yahoo! Web Hosting - establish your business online<BR><BR><BR>-------------------------------------------------------<BR>This SF.net email is sponsored by:Crypto Challenge is now open!<BR>Get cracking and register here for some mind 
 boggling fun and<BR>the chance of winning an Apple iPod:<BR>http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en<BR>_______________________________________________<BR>NFS maillist - NFS@lists.sourceforge.net<BR>https://lists.sourceforge.net/lists/listinfo/nfs</BLOCKQUOTE><p><br><hr size=1>Do you Yahoo!?<br>
<a href="http://webhosting.yahoo.com/ps/wh3/prod/">Yahoo! Web Hosting</a> - establish your business online
--0-368474160-1047407442=:86536--


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
