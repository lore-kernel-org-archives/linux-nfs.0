From: "William A. (Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Tue, 20 Mar 2007 07:24:00 -0400
Message-ID: <89c397150703200424n4921f619heaa47c13482a215a@mail.gmail.com>
References: <17914.20117.186786.830574@notabene.brown>
	<20070316181047.GD4538@fieldses.org>
	<17917.53245.697560.272545@notabene.brown>
	<20070319230213.GD29272@fieldses.org>
	<EXNANE01h7jtrSByh130000010c@exnane01.hq.netapp.com>
	<20070320011458.GA31225@fieldses.org>
	<EXNANE01LoygXLsxpTl0000010f@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1171860552=="
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTcRe-0004Br-U4
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 04:24:03 -0700
Received: from an-out-0708.google.com ([209.85.132.240])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTcRg-0003mI-5E
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 04:24:04 -0700
Received: by an-out-0708.google.com with SMTP id d40so2919386and
	for <nfs@lists.sourceforge.net>; Tue, 20 Mar 2007 04:24:01 -0700 (PDT)
In-Reply-To: <EXNANE01LoygXLsxpTl0000010f@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1171860552==
Content-Type: multipart/alternative;
	boundary="----=_Part_129406_13748660.1174389840979"

------=_Part_129406_13748660.1174389840979
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 3/20/07, Talpey, Thomas <Thomas.Talpey@netapp.com> wrote:
>
> At 09:14 PM 3/19/2007, J. Bruce Fields wrote:
> >Currently we're *not* doing what the rfc suggests--keeping a record
> >with timestamp of first open, etc.--instead we're basically remembering
> >just the one bit per client (is this client known to us or not), which
> >means we *must* synchronously invalidate every client as we exit the
> >grace period.  That's awkward.
>
> Ah, I get it. It has to be invalidated because the state can't be marked
> "out of grace"? The timestamp is the right fix of course, but wouldn't
> a single bit ("known to us" | "out of grace") kinda sorta do it? Then
> invalidation could at least be delayed.
>
> It's a little worse than awkward though. Isn't the server going to return
> BAD_STATEID after this (instead of stale/old)? The server goes from
> serving no state-granting ops, to dropping everything that didn't make
> it back to reclaim in time. The v3 nlm recovery doesn't do that.


No. The stale stateid check is before the bad stateid check
(fs/nfsd/nfs4state.c:nfs4_preprocess_stateid_op) - stale stateid is
returned, which is the correct behavior past reclaim processing.

-->Andy

Tom.
>
>
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share
> your
> opinions on IT & business topics through brief surveys-and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>

------=_Part_129406_13748660.1174389840979
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<br><br><div><span class="gmail_quote">On 3/20/07, <b class="gmail_sendername">Talpey, Thomas</b> &lt;<a href="mailto:Thomas.Talpey@netapp.com">Thomas.Talpey@netapp.com</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
At 09:14 PM 3/19/2007, J. Bruce Fields wrote:<br>&gt;Currently we&#39;re *not* doing what the rfc suggests--keeping a record<br>&gt;with timestamp of first open, etc.--instead we&#39;re basically remembering<br>&gt;just the one bit per client (is this client known to us or not), which
<br>&gt;means we *must* synchronously invalidate every client as we exit the<br>&gt;grace period.&nbsp;&nbsp;That&#39;s awkward.<br><br>Ah, I get it. It has to be invalidated because the state can&#39;t be marked<br>&quot;out of grace&quot;? The timestamp is the right fix of course, but wouldn&#39;t
<br>a single bit (&quot;known to us&quot; | &quot;out of grace&quot;) kinda sorta do it? Then<br>invalidation could at least be delayed.<br><br>It&#39;s a little worse than awkward though. Isn&#39;t the server going to return
<br>BAD_STATEID after this (instead of stale/old)? The server goes from<br>serving no state-granting ops, to dropping everything that didn&#39;t make<br>it back to reclaim in time. The v3 nlm recovery doesn&#39;t do that.
</blockquote><div><br>No. The stale stateid check is before the bad stateid check (fs/nfsd/nfs4state.c:nfs4_preprocess_stateid_op) - stale stateid is returned, which is the correct behavior past reclaim processing.<br><br>
--&gt;Andy<br></div><br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">Tom.<br><br><br>-------------------------------------------------------------------------
<br>Take Surveys. Earn Cash. Influence the Future of IT<br>Join SourceForge.net&#39;s Techsay panel and you&#39;ll get the chance to share your<br>opinions on IT &amp; business topics through brief surveys-and earn cash<br>
<a href="http://www.techsay.com/default.php?page=join.php&amp;p=sourceforge&amp;CID=DEVDEV">http://www.techsay.com/default.php?page=join.php&amp;p=sourceforge&amp;CID=DEVDEV</a><br>_______________________________________________
<br>NFS maillist&nbsp;&nbsp;-&nbsp;&nbsp;<a href="mailto:NFS@lists.sourceforge.net">NFS@lists.sourceforge.net</a><br><a href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a><br><br></blockquote>
</div><br>

------=_Part_129406_13748660.1174389840979--


--===============1171860552==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1171860552==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1171860552==--
