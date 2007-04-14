From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Merge plans for RPC/RDMA? (Was: Re: [PATCH 000 of 14]
 knfsd: Preparation for IPv6 support in NFS server.)
Date: Fri, 13 Apr 2007 21:07:34 -0400
Message-ID: <46202956.3080305@oracle.com>
References: <170fa0d20704131347u4a28b5d1h1959227980449fbf@mail.gmail.com>	
	<46200822.5060800@oracle.com>
	<170fa0d20704131704y13151149n817cd698e22781c8@mail.gmail.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020708090603060108030508"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	Roland Dreier <rdreier@cisco.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcWkc-0004tk-OX
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 18:08:26 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HcWkd-000391-VP
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 18:08:29 -0700
In-Reply-To: <170fa0d20704131704y13151149n817cd698e22781c8@mail.gmail.com>
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

This is a multi-part message in MIME format.
--------------020708090603060108030508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Mike Snitzer wrote:
> On 4/13/07, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Mike Snitzer wrote:
>> > On 2/2/07, Chuck Lever <chuck.lever@oracle.com> wrote:
>> >> Roland Dreier wrote:
>> >> >  > They are mostly from Chuck Level and make preparating for IPv6
>> >> support
>> >> >  > in the NFS server.
>> >> >  > They are *not* for 2.6.20, but should be ok for .21.
>> >> >
>> >> > Out of curiousity, does this patch series reduce the delta 
>> between the
>> >> > NFS/RDMA tree and mainline Linux?  In other words does this bring
>> >> > NFS/RDMA closer to merging?
>> >>
>> >> Hi Roland-
>> >>
>> >> The client side support for an RPC/RDMA module is almost completely
>> >> integrated into mainline.  There is still a minimal set of patches
>> >> required to support alternate transports in loadable kernel modules
>> >> which Trond has indicated he will integrate when the RPC/RDMA 
>> transport
>> >> is ready to be integrated.
>> >
>> > Hi Chuck,
>> >
>> > I must be missing something because I don't see _any_ trace of the
>> > core RPC over RDMA support (xprtrdma et al), your RPC Transport
>> > Switch, or any of the other supporting changes in mainline.  Could
>> > you, or others, please clarify the plan for merging RPC/RDMA?
>>
>> The RPC transport switch patches are almost fully integrated into
>> mainline.  The xprtrdma piece is what is not there yet.
> 
> OK, has the xprtrdma piece been reviewed by the community?  What, if
> anything, is preventing the code from being included in -mm for wider
> testing?

Some of the main NFS client developers (Trond, the CITI-UM developers, 
myself) have reviewed previous versions of this code, and have 
recommended a number of changes.  I haven't heard anything recently from 
the NetApp engineers working on this.  We are waiting for them to 
publish again, but I think they are waiting for the last of the 
transport switch patches to trickle into mainline (which should be ready 
with the release of 2.6.21).  I know they have been working with a 
handful of test sites and have achieved good performance results.

> Has xprtrdma inclusion/progress been discussed on some other mailing
> list?

Not yet, but the place that is likely to occur is nfs@lists.sourceforge.net.

--------------020708090603060108030508
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------020708090603060108030508
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------020708090603060108030508
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020708090603060108030508--
