From: Juan Gomez <j_carlos_gomez@yahoo.com>
Subject: Re: PATCH(nfs-utils) Fix bug in statd notify mode
Date: Fri, 11 Oct 2002 00:24:16 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021011072416.26364.qmail@web13504.mail.yahoo.com>
References: <15782.27996.915466.3245@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-777147138-1034321056=:26157"
Cc: nfs@lists.sourceforge.net, juang@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web13504.mail.yahoo.com ([216.136.175.83])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zu9h-0002e1-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 00:24:17 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15782.27996.915466.3245@notabene.cse.unsw.edu.au>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

--0-777147138-1034321056=:26157
Content-Type: text/plain; charset=us-ascii


Neil,
Thanks a bunch, that other pmap_unset() was good catch, it scaped my attention!
Juan
 
 Neil Brown <neilb@cse.unsw.edu.au> wrote:On Wednesday October 9, gomez@cs.sjsu.edu wrote:
> 
> Neil,
> 
> While further testing the statd mode I introduced previously (-N opt) I
> found that
> I forgot to skip pmap_unset() while in the notify mode.
> 
> If we do not do that a statd running in notify mode will disable
> any other local statd running in the non-notify mode which is undesirable.
> 
> Would you please apply the current patch to the HEAD of the cvs repository
> for nfs-utils?

Ok, it's checked in.

I also protected the pmap_unset in 'killer' (called if statd gets a
signal) so that it only runs if not MODE_NOTIFY_ONLY.

NeilBrown

> 
> Regards, Juan
> 
> diff -ur nfs-utils/utils/statd/statd.c nfs-utils-new/utils/statd/statd.c
> --- nfs-utils/utils/statd/statd.c Sun Sep 1 19:31:23 2002
> +++ nfs-utils-new/utils/statd/statd.c Wed Oct 9 22:28:26 2002
> @@ -307,7 +307,14 @@
> statd_get_socket(out_port);
> 
> for (;;) {
> - pmap_unset (SM_PROG, SM_VERS);
> + /* Do not do pmap_unset() when running in notify mode.
> + * We may clear the portmapper record for a statd not
> + * running in notify mode disabling it.
> + * Juan C. Gomez j_carlos_gomez@yahoo.com
> + */
> + if (!(run_mode & MODE_NOTIFY_ONLY)) {
> + pmap_unset (SM_PROG, SM_VERS);
> + }
> change_state ();
> shuffle_dirs (); /* Move directory names around */
> notify_hosts (); /* Send out notify requests */


---------------------------------
Do you Yahoo!?
Faith Hill - Exclusive Performances, Videos, & more
faith.yahoo.com
--0-777147138-1034321056=:26157
Content-Type: text/html; charset=us-ascii

<P>Neil,
<P>Thanks a bunch, that other pmap_unset() was good catch, it scaped my attention!
<P>Juan
<P>&nbsp;
<P>&nbsp;<B><I>Neil Brown &lt;neilb@cse.unsw.edu.au&gt;</I></B> wrote:
<BLOCKQUOTE style="PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #1010ff 2px solid">On Wednesday October 9, gomez@cs.sjsu.edu wrote:<BR>&gt; <BR>&gt; Neil,<BR>&gt; <BR>&gt; While further testing the statd mode I introduced previously (-N opt) I<BR>&gt; found that<BR>&gt; I forgot to skip pmap_unset() while in the notify mode.<BR>&gt; <BR>&gt; If we do not do that a statd running in notify mode will disable<BR>&gt; any other local statd running in the non-notify mode which is undesirable.<BR>&gt; <BR>&gt; Would you please apply the current patch to the HEAD of the cvs repository<BR>&gt; for nfs-utils?<BR><BR>Ok, it's checked in.<BR><BR>I also protected the pmap_unset in 'killer' (called if statd gets a<BR>signal) so that it only runs if not MODE_NOTIFY_ONLY.<BR><BR>NeilBrown<BR><BR>&gt; <BR>&gt; Regards, Juan<BR>&gt; <BR>&gt; diff -ur nfs-utils/utils/statd/statd.c nfs-utils-new/utils/statd/statd.c<BR>&gt; --- nfs-utils/utils/statd/statd.c Sun Sep 1 19:31:23 2002<BR>&gt; ++
 + nfs-utils-new/utils/statd/statd.c Wed Oct 9 22:28:26 2002<BR>&gt; @@ -307,7 +307,14 @@<BR>&gt; statd_get_socket(out_port);<BR>&gt; <BR>&gt; for (;;) {<BR>&gt; - pmap_unset (SM_PROG, SM_VERS);<BR>&gt; + /* Do not do pmap_unset() when running in notify mode.<BR>&gt; + * We may clear the portmapper record for a statd not<BR>&gt; + * running in notify mode disabling it.<BR>&gt; + * Juan C. Gomez j_carlos_gomez@yahoo.com<BR>&gt; + */<BR>&gt; + if (!(run_mode &amp; MODE_NOTIFY_ONLY)) {<BR>&gt; + pmap_unset (SM_PROG, SM_VERS);<BR>&gt; + }<BR>&gt; change_state ();<BR>&gt; shuffle_dirs (); /* Move directory names around */<BR>&gt; notify_hosts (); /* Send out notify requests */</BLOCKQUOTE><p><br><hr size=1>Do you Yahoo!?<br>
<a href="http://faith.yahoo.com">Faith Hill</a> - Exclusive Performances, Videos, & more<br>
<a href="http://faith.yahoo.com">faith.yahoo.com</a>
--0-777147138-1034321056=:26157--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
