From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Tue, 25 Jul 2006 10:05:53 -0400
Message-ID: <76bd70e30607250705h3e8c9eefjc794397e0c45a21b@mail.gmail.com>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5NXn-000619-Mh
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 07:05:55 -0700
Received: from nf-out-0910.google.com ([64.233.182.186])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5NXm-0000LT-PX
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 07:05:56 -0700
Received: by nf-out-0910.google.com with SMTP id m19so222651nfc
	for <nfs@lists.sourceforge.net>; Tue, 25 Jul 2006 07:05:53 -0700 (PDT)
To: "Neil Brown" <neilb@suse.de>
In-Reply-To: <17605.50325.842862.8823@cse.unsw.edu.au>
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

On 7/25/06, Neil Brown <neilb@suse.de> wrote:
> On Tuesday July 25, gnb@melbourne.sgi.com wrote:
> > G'day,
> >
> >
> > 001 knfsd: move tempsock aging to timer
>
> Looks good.
> Has the subtle side effect that when we reach our limit on the number
> of permitted tcp connections, the one that is discarded is the one
> that has been open the longest, rather than the one that has be unused
> for the longest.  The comment there says
>                         /*
>                          * Always select the oldest socket. It's not fair,
>                          * but so is life
>                          */
> so I guess it is still correct ('oldest' is ambiguous).  The new
> situation is probably equally (un)fair - would you agree?

Ouch.  IMO this will penalize long-running workloads unnecessarily,
and will likely be much more of a performance hit for such workloads
than would be gained by improving the CPU cache behavior on the
server.

The previous algorithm (close the least recently used socket) is more fair.

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
