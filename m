From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: NFS Help! Terrible performance with sync,
	fast performance with async
Date: Sun, 19 Nov 2006 22:08:53 -0500
Message-ID: <76bd70e30611191908u70f476f8iaf825ccc811367c@mail.gmail.com>
References: <49BCFA109293624D9AE0EC6558C0D3B802A8B327@ATL1VEXC017.usdom004.tco.tc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GlzWj-0001EJ-Vr
	for nfs@lists.sourceforge.net; Sun, 19 Nov 2006 19:08:58 -0800
Received: from nf-out-0910.google.com ([64.233.182.187])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GlzWk-0000xN-B1
	for nfs@lists.sourceforge.net; Sun, 19 Nov 2006 19:08:59 -0800
Received: by nf-out-0910.google.com with SMTP id c31so3809342nfb
	for <nfs@lists.sourceforge.net>; Sun, 19 Nov 2006 19:08:54 -0800 (PST)
To: "Chris Wornell" <CWornell@peerless.com>
In-Reply-To: <49BCFA109293624D9AE0EC6558C0D3B802A8B327@ATL1VEXC017.usdom004.tco.tc>
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

On 11/19/06, Chris Wornell <CWornell@peerless.com> wrote:
>  Another question is I don't quite understand how the data corruption
> happens if a power loss occurs on an NFS server using async. Even with sync,
> data transferred over the wire maybe loss if the nfs server gets shut down
> before that data is committed. Can anyone go into more detail on how the
> data corruption happens?

Have a look at

http://nfs.sourceforge.net/#faq_b6

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
