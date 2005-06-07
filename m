From: Sven Geggus <sven@geggus.net>
Subject: Re: 2.4 -> 2.6 transition major performance issues
Date: Tue, 7 Jun 2005 16:37:21 +0200
Message-ID: <20050607143720.GA26081@geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DffCq-0000vL-TF
	for nfs@lists.sourceforge.net; Tue, 07 Jun 2005 07:37:28 -0700
Received: from dolly.gnuher.de ([212.227.64.154])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DffCo-0003HX-AE
	for nfs@lists.sourceforge.net; Tue, 07 Jun 2005 07:37:28 -0700
Received: from benzin.geggus.net ([2001:8d8:81:672::1])
	by dolly.gnuher.de with esmtpsa TLS-1.0:RSA_AES_256_CBC_SHA:32
	(Exim 4.50 id 1DffCl-0001iY-Do)
	for <nfs@lists.sourceforge.net>; Tue, 07 Jun 2005 16:37:23 +0200
Received: from sven by benzin.geggus.net with local
	(Exim 4.50 id 1DffCj-0006mq-Ec)
	for <nfs@lists.sourceforge.net>; Tue, 07 Jun 2005 16:37:21 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>> Do you have any hint where I could start to debug this? I already made
>> shure, that NFSv3 is used in any case.
> 
>   http://nfs.sourceforge.net/#faq_b1

I already read the FAQ. rsize and wsize values of the client are already set
to 8192 and NFS over TCP did not solve the Problem either :(

As I already said, all I did change on the Server is Kernel Versions. The
whole stuff works perfect with Kernel 2.4.31 and is dead slow starting from
Kernel 2.6.9 (the first 2.6 Kernel I tried to use) to Kernel 2.6.11.10 (the
latest 2.6 Kernel I tried to use). It is slow because nfsd seems to eat all
my CPU when NFS is in heavy use.

B10 in the FAQ is exactly the Problem I seem to have, but the solutions
proposed do net seem to match my case :(

I neighter have some ancient Kernel (<= 2.4.20) nor do I have a complex
network setup (just one single switch between the client and the Server
machine).

BTW, both machines are x86-32 architecture.

Sven

-- 
"In the land of the brave and the free, we defend our freedom
with the GNU GPL" (Richard M. Stallman on www.gnu.org)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
