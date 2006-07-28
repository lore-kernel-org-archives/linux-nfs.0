From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: default sunrpc.min_resvport
Date: Thu, 27 Jul 2006 22:42:33 -0400
Message-ID: <76bd70e30607271942w6784ae82i4b14ca0b95fddcf2@mail.gmail.com>
References: <168996D6C4DFA945B032B63C0DEAA6BF0421E687@EXCHANGE1.postini.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6IJA-0008Gc-Gz
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 19:42:36 -0700
Received: from nf-out-0910.google.com ([64.233.182.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G6IJ9-0003R8-AD
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 19:42:37 -0700
Received: by nf-out-0910.google.com with SMTP id m19so72108nfc
	for <nfs@lists.sourceforge.net>; Thu, 27 Jul 2006 19:42:33 -0700 (PDT)
To: "Michael Han" <mhan@postini.com>
In-Reply-To: <168996D6C4DFA945B032B63C0DEAA6BF0421E687@EXCHANGE1.postini.com>
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

On 7/26/06, Michael Han <mhan@postini.com> wrote:
> I'm not sure if this has surfaced before for discussion (searching
> hasn't shown me any relevant threads), but the 2.6 kernel's new
> implementation of xprt_bindresvport can conflict with port 664 on
> IPMI-enabled hosts with a BMC. IPMI uses both ports 623 and 664 for
> communications, and several implementations appear to intercept all
> traffic for these ports and not permit them to pass to the standard
> packet driver (tcpdump in promiscuous mode shows no packets coming in).
>
> I know that in the discussions back in 2005/02 and 2005/07 of the patch
> that implements the new privileged port binding for NFS mount (I can't
> tell whose patch it is, perhaps Olaf Kirch's?), Charles Lever noted that
> the new sunrpc.min_resvport of 650 avoids conflicts with port 623. Is it
> worth increasing this default to 665 to avoid this port as well?
>
> If not, I just wanted to get this information onto the list, since I
> searched pretty heavily while researching the intermittent hangs I've
> been getting with my NFS mounts before finally nailing this to my IPMI
> BMCs. Manually setting sunrpc.min_resvport to 700 has stabilized NFS on
> my boxes. Thanks.

Michael-

IPMI port number collisions are particularly hard to diagnose.
Congratulations on tracking this down.

Raising the minimum port number is one way to avoid port number
collisions.  However, you are chopping away a lot of usable ports when
you do this, something that some sites can't afford.  Especially if
you use automounter, or expect your clients to support more than a
couple hundred NFS mounts at once, you will probably need the expanded
port space.

A better way to eliminate the problem is to start a dummy daemon on
port 664 (or any other ports that the hardware might use
"transparently") so that the RPC client entirely avoids choosing those
port numbers.  I believe that some enterprise distributions (RHEL?  I
can't remember) have chosen to provide such daemons for just this
purpose.

Ask your distributor for more detail on this.

In the meantime, we should consider raising the default minimum port
number by 15 (or if we wanted to be particularly evil, we should chose
666 and be done with it).

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
