From: Abhishek Rai <abbashake007@yahoo.com>
Subject: regarding size limit of local client cache
Date: Mon, 10 Mar 2003 23:33:14 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030311073314.12081.qmail@web11407.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-71814958-1047367994=:11574"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web11407.mail.yahoo.com ([216.136.131.237])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18seGB-0007sb-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Mar 2003 23:33:15 -0800
To: nfs@lists.sourceforge.net
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

--0-71814958-1047367994=:11574
Content-Type: text/plain; charset=us-ascii


hi, 

this query arises from some small experiments i performed with my linux nfs client (2.4.18). 

Conclusions first:- There is a limit of 8192 pages on the size of the local client cache and this space is shared between the various nfs mounts currently operating on this machine with this machine as the client.

Question 1. I haven't been able to trace this 8192 pages limit to any data structure or functionality - so please help

Question 2 : This question is regarding the management of this shared cache, space freeing mechanism in the cache to make space for fresh reads etc and arises from the following observations :-

I conducted the following experiments:- 'n' nfs clients (numbered 1, 2, 3) are currently mounted, reading 3 different non-overlapping directory trees of some server. The events proceed as follows when n=2,

client 1 reads 4096 4k pages from the server. Then, client 2 reads 4096 4k pages(different from those read by 1) from the server.

client 1 again reads 4096 pages from the server followed by client 2 repeating the same. Except for the first read whent the cache is cold, no later reads translate into an on-the-wire read.

<< just to add: i concluded of the 8192 pages limit from the following 3 observations: (1). when i made the two clients read 8192 pages each alternatively, every read all through caused an on-the-wire-lookup, (2). when only one client was repeatedly reading 8192 pages, the cache completely satisfied all but the first request, (3). when only one client was repeatedly reading 16384 pages, every read translated into an on-the-wire read.>>

Now i made n=3. (no. of pages being read by each client continue to be 4096)

I tried out two different orderings of client reads - <1,2,3,1,2,3> and <1,2,3,2,1>

In both these cases, __ALL__ reads translate into an on-the-wire read. I expected some requirement based freeing of space in the client cache to make space for say 3 after 1 and 2 have done their reads eg. if global lru based freeing then in <123123>, 3 would cause 1's 4096 pages to be thrown out of the cache to make space for its own 4096. And after that in the next cycle, 1 would cause the same to 2... which would mean all reads=on-the-wire-read. But this scenario would imply that in <12321>, the second time 2 is around it would find its data still in the cache, only 1 will suffer etc but this wasn't found to be the case. So when space is needed - the space freeing protocol recklessly frees all possible space ? no- global lru based freeing mechanism ? at least let me know where lies the corresponding code. thanks a lot.

Question 3: server->nr_requests is limited by the hard limit MAX_REQUEST_HARD. what is this server->nr_requests ? outstanding unsatisfied requests ? Again where is the limit for cache size ?

Thanks in advance

cheers

Abhishek



---------------------------------
Do you Yahoo!?
Yahoo! Web Hosting - establish your business online
--0-71814958-1047367994=:11574
Content-Type: text/html; charset=us-ascii

<P>hi, </P>
<P>this query arises from some small experiments i performed with my linux nfs client (2.4.18). </P>
<P>Conclusions first:- There is a limit of 8192 pages on the size of the local client cache and this space is shared between the various nfs mounts currently operating on this machine with this machine as the client.</P>
<P>Question 1. I haven't been able to trace this 8192 pages limit to any data structure or functionality - so please help</P>
<P>Question 2 : This question is regarding the management of this shared cache, space freeing mechanism in the cache to make space for fresh reads etc and arises from the following observations :-</P>
<P>I conducted the following experiments:- 'n' nfs clients (numbered 1, 2, 3) are currently mounted, reading 3 different non-overlapping directory trees of some server. The events proceed as follows when n=2,</P>
<P>client 1 reads 4096 4k pages from the server. Then, client 2 reads 4096 4k pages(different from those read by 1) from the server.</P>
<P>client 1 again reads 4096 pages from the server followed by client 2 repeating the same. Except for the first read whent the cache is cold, no later reads translate into an on-the-wire read.</P>
<P>&lt;&lt; just to add: i concluded of the 8192 pages limit from the following 3 observations: (1). when i made the two clients read 8192 pages each alternatively, every read all through caused an on-the-wire-lookup, (2). when only one client was repeatedly reading 8192 pages, the cache completely satisfied all but the first request, (3). when only one client was repeatedly reading 16384 pages, every read translated into an on-the-wire read.&gt;&gt;</P>
<P>Now i made n=3. (no. of pages being read by each client continue to be 4096)</P>
<P>I tried out two different orderings of client reads - &lt;1,2,3,1,2,3&gt; and &lt;1,2,3,2,1&gt;</P>
<P>In both these cases, __ALL__ reads translate into an on-the-wire read. I expected some requirement based freeing of space in the client cache to make space for say 3 after 1 and 2 have done their reads eg. if global lru based freeing then in &lt;123123&gt;, 3 would cause 1's 4096 pages to be thrown out of the cache to make space for its own 4096. And after that in the next cycle, 1 would cause the same to 2... which would mean all reads=on-the-wire-read. But this scenario would imply that in &lt;12321&gt;, the second time 2 is around it would find its data still in the cache, only 1 will suffer etc but this wasn't found to be the case. So when space is needed - the space freeing protocol recklessly frees all possible space ? no- global lru based freeing mechanism ? at least let me know where lies the corresponding code. thanks a lot.</P><FONT face=Arial size=2>
<P>Question 3: server-&gt;nr_requests is limited by the hard limit MAX_REQUEST_HARD. what is this server-&gt;nr_requests ? outstanding unsatisfied requests ? Again where is the limit for cache size ?</P>
<P>Thanks in advance</P>
<P>cheers</P>
<P>Abhishek</P></FONT><p><br><hr size=1>Do you Yahoo!?<br>
<a href="http://webhosting.yahoo.com/ps/wh3/prod/">Yahoo! Web Hosting</a> - establish your business online
--0-71814958-1047367994=:11574--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
