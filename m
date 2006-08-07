From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 003 of 4] Prepare knfsd for support of rsize/wsize
	of up to 1MB, over TCP.
Date: Mon, 7 Aug 2006 09:04:00 -0400
Message-ID: <76bd70e30608070604r5da3fefds4fea763336221403@mail.gmail.com>
References: <20060807103020.12286.patches@notabene>
	<1060807003515.12391@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GA4m4-000075-26
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 06:04:04 -0700
Received: from nf-out-0910.google.com ([64.233.182.186])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GA4m3-00062g-7t
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 06:04:04 -0700
Received: by nf-out-0910.google.com with SMTP id a27so834494nfc
	for <nfs@lists.sourceforge.net>; Mon, 07 Aug 2006 06:04:01 -0700 (PDT)
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060807003515.12391@suse.de>
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

Hi Neil-

On 8/6/06, NeilBrown <neilb@suse.de> wrote:
>
> The limit over UDP remains at 32K.  Also, make some of
> the apparently arbitrary sizing constants clearer.
>
> The biggest change here involves replacing NFSSVC_MAXBLKSIZE
> by a function of the rqstp.  This allows it to be different
> for different protocols (udp/tcp) and also allows it
> to depend on the servers declared sv_bufsiz.
>
> Note that we don't actually increase sv_bufsz for nfs yet.
> That comes next.
>
> From: Greg Banks <gnb@melbourne.sgi.com>
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> Signed-off-by: Neil Brown <neilb@suse.de>

I know the name NFSSVC_MAXBLKSIZE is historical, but to me it is
confusing.  It isn't a block size at all, it's really a maximum
tranfser size, in bytes, right?

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
