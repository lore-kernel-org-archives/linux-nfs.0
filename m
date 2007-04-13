From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Merge plans for RPC/RDMA? (Was: Re: [PATCH 000 of 14]
 knfsd: Preparation for IPv6 support in NFS server.)
Date: Fri, 13 Apr 2007 18:45:54 -0400
Message-ID: <46200822.5060800@oracle.com>
References: <170fa0d20704131347u4a28b5d1h1959227980449fbf@mail.gmail.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060407010706070108020908"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	Roland Dreier <rdreier@cisco.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcUXj-0007Sn-Kb
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 15:46:59 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HcUXk-0007iZ-Qq
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 15:47:02 -0700
In-Reply-To: <170fa0d20704131347u4a28b5d1h1959227980449fbf@mail.gmail.com>
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
--------------060407010706070108020908
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Mike Snitzer wrote:
> On 2/2/07, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Roland Dreier wrote:
>> >  > They are mostly from Chuck Level and make preparating for IPv6 
>> support
>> >  > in the NFS server.
>> >  > They are *not* for 2.6.20, but should be ok for .21.
>> >
>> > Out of curiousity, does this patch series reduce the delta between the
>> > NFS/RDMA tree and mainline Linux?  In other words does this bring
>> > NFS/RDMA closer to merging?
>>
>> Hi Roland-
>>
>> The client side support for an RPC/RDMA module is almost completely
>> integrated into mainline.  There is still a minimal set of patches
>> required to support alternate transports in loadable kernel modules
>> which Trond has indicated he will integrate when the RPC/RDMA transport
>> is ready to be integrated.
> 
> Hi Chuck,
> 
> I must be missing something because I don't see _any_ trace of the
> core RPC over RDMA support (xprtrdma et al), your RPC Transport
> Switch, or any of the other supporting changes in mainline.  Could
> you, or others, please clarify the plan for merging RPC/RDMA?

The RPC transport switch patches are almost fully integrated into 
mainline.  The xprtrdma piece is what is not there yet.

>> At this time I'm not aware of a plan to integrate server-side support
>> for NFS/RDMA.  Perhaps the NetApp RDMA developers could respond.
> 
> Do you mean the NFS/RDMA server code from Tom Tucker of Open Grid
> Computing?  Why wouldn't this code be included?

Tom's code hasn't been reviewed by the community.

--------------060407010706070108020908
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


--------------060407010706070108020908
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------060407010706070108020908
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060407010706070108020908--
