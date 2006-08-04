From: Wendy Cheng <wcheng@redhat.com>
Subject: [Fwd: [Cluster-devel] Re:  [PATCH 0/3] NLM lock failover]
Date: Fri, 04 Aug 2006 00:13:39 -0400
Message-ID: <1154664819.3429.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Uszd4CBnXBBnlXbV8Yfk"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8qt5-0003e0-J2
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 21:02:17 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G8qt5-0003Wn-Nq
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 21:02:16 -0700
To: neilb@suse.de
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


--=-Uszd4CBnXBBnlXbV8Yfk
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Previous mail gets bounced back... Resend ... Wendy

--=-Uszd4CBnXBBnlXbV8Yfk
Content-Disposition: inline
Content-Description: Forwarded message - [Cluster-devel] Re: [NFS] [PATCH
	0/3] NLM lock failover
Content-Type: message/rfc822

Return-Path: <cluster-devel-bounces@redhat.com>
Received: from localhost.localdomain ([unix socket]) by
	pobox.corp.redhat.com (Cyrus v2.2.12-Invoca-RPM-2.2.12-3.RHEL4.1) with
	LMTPA; Thu, 03 Aug 2006 17:37:48 -0400
X-Sieve: CMU Sieve 2.2
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254]) by localhost.localdomain (8.13.1/8.12.8) with ESMTP id
	k73LbmIM019046; Thu, 3 Aug 2006 17:37:48 -0400
Received: from mx1.util.phx.redhat.com (mx1.util.phx.redhat.com
	[10.8.4.92]) by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with
	ESMTP id k73LblSI002136; Thu, 3 Aug 2006 17:37:47 -0400
Received: from hormel.redhat.com (hormel.util.phx.redhat.com [10.8.4.111])
	by mx1.util.phx.redhat.com (8.13.1/8.13.1) with ESMTP id k73Lbg7E007854;
	Thu, 3 Aug 2006 17:37:42 -0400
Received: from listman.util.phx.redhat.com (listman.util.phx.redhat.com
	[10.8.4.110]) by hormel.redhat.com (Postfix) with ESMTP id 6A539731FC;
	Thu, 3 Aug 2006 17:37:42 -0400 (EDT)
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254]) by listman.util.phx.redhat.com (8.13.1/8.13.1) with
	ESMTP
	id k73Lbe6X018053 for <cluster-devel@listman.util.phx.redhat.com>;
	Thu, 3 Aug 2006 17:37:40 -0400
Received: from wendyc.rdu.redhat.com
	(IDENT:U2FsdGVkX1/UoRWlC5YxH+Scbr8tXsWqMsbjlzzTVl0@wendyc.rdu.redhat.com
	[172.16.59.28]) by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11)
	with ESMTP id k73LbehJ002133; Thu, 3 Aug 2006 17:37:40 -0400
Received: from [127.0.0.1] (localhost.localdomain [127.0.0.1]) by
	wendyc.rdu.redhat.com (8.12.11/8.12.11) with ESMTP id k73LYtcS012544;
	Thu, 3 Aug 2006 17:34:55 -0400
Message-ID: <44D26BFF.9090506@redhat.com>
Date: Thu, 03 Aug 2006 17:34:55 -0400
From: Wendy Cheng <wcheng@redhat.com>
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.7)
	Gecko/20050427 Red Hat/1.7.7-1.1.3.4
X-Accept-Language: en-us, en
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
References: <44A41246.2070106@redhat.com>
	<1154397341.3378.10.camel@localhost.localdomain>
	<17617.30732.643539.353696@cse.unsw.edu.au>
In-Reply-To: <17617.30732.643539.353696@cse.unsw.edu.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
X-loop: cluster-devel@redhat.com
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
Subject: [Cluster-devel] Re: [NFS] [PATCH 0/3] NLM lock failover
X-BeenThere: cluster-devel@redhat.com
X-Mailman-Version: 2.1.5
Precedence: junk
List-Id: "\[Cluster devel\]" <cluster-devel.redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
Content-Transfer-Encoding: 7bit

Neil Brown wrote:

>First note:  it helps a lot if the Subject line for each patch
>contains a distinctive short description of what the patch does.
>  
>
This is due to inexperience with open source patch submission plus 
end-of-day fatigue :) .. It will be improved.

>>PATCH 1/3
>>---------
>>This patch makes an assumption that any given filehandle will only arrive at
>>one particular interface - never more.  This is implicit in the fact
>>that f_iaddr is stored in 'struct nlm_file' which is indexed by
>>filehandle.
>>
>>.....
>>
>>A consequence of this is that you cannot have a virtual server with
>>two (or more interfaces).  Is this likely to be a problem?
>>e.g. if you have 4 physical interfaces on your server, might you want
>>to bind a different IP to each for each virtual server?
>>If you did, then my change above would mean that you couldn't do
>>failover, and we might need to look at other options...
>>
>>Possibly (and maybe this is more work than is justified), lockd can
>>monitor interface usage and deduce interface pools based on seeing the
>>same filehandle on multiple interfaces.  Then when an unlock request
>>arrives on nlm_unlock, lockd would require all interfaces that touched
>>a file to be 'unlocked' before actually dropping the locks on the
>>file.
>>
>>As you can probably tell I was "thinking out loud" there and it may
>>not be particularly coherent or cohesive.   
>>
>>Do you have any thoughts on this issues?
>>    
>>
Another option is dropping the (NLM) locks based on "fsid" (that can be 
retrieved from filehandle), instead of virtual ip address. Note that 
"fsid" has a good use in a cluster environment (compared to device 
major/minor since different nodes may have different device numbers). 
See any bad thing about fsid approach ?

One catch (about fsid) I can think of is that it must be passed from 
lockd to statd (then to ha-callout program). Current SM_MON and SM_UNMON 
protocol doesn't have any extra field for us to do that. Will add one 
more field causing any issue ? e.g.

current SM_MON argument

string<1024> mon_name;
string<1024> my_name;
unit32 my_prog;
unit32 my_vers;
unit32 my_proc;
opaque[16] priv;

Will add "opaque[16] fsid" after "priv" be ok ?  Ditto for SM_UNMON. On 
the other hand, the fsid can be the 4th parameter to pass to ha-callout 
program (then, that we can avoid breaking any existing ha-callup 
application).

Lets give it few more days to think these issues over.

All others (comments for PATCH 2/3 and 3/3) are helpful coding advices - 
they are appreciated and changes will be made accordingly.

-- Wendy



--=-Uszd4CBnXBBnlXbV8Yfk
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-Uszd4CBnXBBnlXbV8Yfk
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-Uszd4CBnXBBnlXbV8Yfk--
