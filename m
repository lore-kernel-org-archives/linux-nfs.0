From: Abhishek Rai <abbashake007@yahoo.com>
Subject: Re: regarding size limit of local client cache
Date: Tue, 11 Mar 2003 13:12:31 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030311211231.55780.qmail@web11407.mail.yahoo.com>
References: <shssmttiwax.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-587211848-1047417151=:55760"
Cc: Abhishek Rai <abbashake007@yahoo.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web11407.mail.yahoo.com ([216.136.131.237])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18sr31-0005he-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 13:12:31 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
  "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <shssmttiwax.fsf@charged.uio.no>
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

--0-587211848-1047417151=:55760
Content-Type: text/plain; charset=us-ascii


But in any case, I have a large swap partition(500 MB). So why doesn't the NFS client make use of the swap space to enlarge its available page cache space rather than restricting its page cache usage to 8192 -4k pages and thus paying the penalty of a very high numbe of on the wire reads.(As i mentioned before, there is negligible load on the client apart from the NFS)

 Trond Myklebust <trond.myklebust@fys.uio.no> wrote:>>>>> " " == Charles Lever writes:

> hi- you didn't tell us how large your client's RAM is, what
> your mount options are, what other programs are running on the
> clients, nor how long each client takes to read (attribute
> cache invalidation might cause each client to purge its cache,
> for instance).

> as far as i know there is no 8192 page limit in the NFS client.

Right. The size of the page cache is limited only by the available
free memory.

Cheers,
Trond


---------------------------------
Do you Yahoo!?
Yahoo! Web Hosting - establish your business online
--0-587211848-1047417151=:55760
Content-Type: text/html; charset=us-ascii

<P>But in any case, I have a large swap partition(500 MB). So why doesn't the NFS client make use of the swap space to enlarge its available page cache space rather than restricting its page cache usage to 8192 -4k pages and thus paying the penalty of a very high numbe of on the wire reads.(As i mentioned before, there is negligible load on the client apart from the NFS)</P>
<P>&nbsp;<B><I>Trond Myklebust &lt;trond.myklebust@fys.uio.no&gt;</I></B> wrote:
<BLOCKQUOTE style="PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #1010ff 2px solid">&gt;&gt;&gt;&gt;&gt; " " == Charles Lever <LEVER>writes:<BR><BR>&gt; hi- you didn't tell us how large your client's RAM is, what<BR>&gt; your mount options are, what other programs are running on the<BR>&gt; clients, nor how long each client takes to read (attribute<BR>&gt; cache invalidation might cause each client to purge its cache,<BR>&gt; for instance).<BR><BR>&gt; as far as i know there is no 8192 page limit in the NFS client.<BR><BR>Right. The size of the page cache is limited only by the available<BR>free memory.<BR><BR>Cheers,<BR>Trond</BLOCKQUOTE><p><br><hr size=1>Do you Yahoo!?<br>
<a href="http://webhosting.yahoo.com/ps/wh3/prod/">Yahoo! Web Hosting</a> - establish your business online
--0-587211848-1047417151=:55760--


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
