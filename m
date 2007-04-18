From: Wendy Cheng <wcheng@redhat.com>
Subject: [Fwd: [PATCH 0/4 Revised] NLM - lock failover]
Date: Tue, 17 Apr 2007 22:11:13 -0400
Message-ID: <46257E41.4060606@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070506050901040505030400"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdzTe-00026D-9b
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 19:01:04 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdzTg-0005Dn-AB
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 19:01:00 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3I20xVH013577
	for <nfs@lists.sourceforge.net>; Tue, 17 Apr 2007 22:00:59 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3I20wfW000502
	for <nfs@lists.sourceforge.net>; Tue, 17 Apr 2007 22:00:58 -0400
Received: from [10.11.14.98] (vpn-14-98.rdu.redhat.com [10.11.14.98])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l3I20wJq007500
	for <nfs@lists.sourceforge.net>; Tue, 17 Apr 2007 22:00:58 -0400
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
--------------070506050901040505030400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The post doesn't seem to go thru.. resend... Wendy

--------------070506050901040505030400
Content-Type: message/rfc822;
	name="Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover"

Message-ID: <4625204D.1030509@redhat.com>
Date: Tue, 17 Apr 2007 15:30:21 -0400
From: Wendy Cheng <wcheng@redhat.com>
User-Agent: Thunderbird 1.5.0.7 (X11/20060913)
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: nfs@lists.sourceforge.net,  cluster-devel@redhat.com
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
References: <46156F3F.3070606@redhat.com>
In-Reply-To: <46156F3F.3070606@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Few new thoughts from the latest round of review are really good and 
worth doing....

However, since this particular NLM patch set is only part of the overall 
scaffolding code to allow NFS V3 server fail over before NFS V4 is 
widely adopted and stabilized, I'm wondering whether we should drag 
ourselves too far for something that will be replaced soon. Lon and I 
had been discussing the possibility of proposing new design changes into 
the existing state monitoring protocol itself - but I'm leaning toward 
*not* doing client SM_NOTIFY eventually (by passing the lock states 
directly from fail-over server to take-over server if all possible). 
This would consolidate few next work items such as NFSD V3 request reply 
cache entires (or at least non-idempotent operation entries) or NFS V4 
states that need to get moved around between the fail over servers.

In general, NFS cluster failover has been error prone and has timing 
constraints (e.g. failover must finish within a sensible time interval). 
Would it make more sense to have a workable solution with restricted 
application first ? We can always merge various pieces together later as 
we learn more from our users. For this reasoning, simple and plain 
patches like this set would work best for now.

In any case, the following collect the review comments so far:

o 1-1 [from hch]
"Dropping locks should also support uuid or dev_t based exports."

A valid request. The easiest solution might be simply taking Neil's idea 
by using export path name. So this issue is combined into 1-3 (see below 
for details).

o 1-2 [from hch]
"It would be nice to have a more general push api for changes to 
filesystem state, that works on a similar basis as getting information 
from /etc/exports."

Could hch (or anyone) elaborate more on this ? Should I interpret it as 
implementing a configuration file (that describes the failover options 
that has a format similar to /etc/exports (including filesystem 
identifiers, the length of grace period, etc) and a command (maybe two - 
one on failover server and one on take-over server) to kick off the 
failover based on the pre-defined configuration file ?

o 1-3 [from neilb]
"It would seem to make more sense to use the filesystem name (i.e. a 
path) by writing a directory name to /proc/fs/nfsd/nlm_unlock and maybe 
also to /proc/fs/nlm_restart_grace_for_fs" and have 'my_name' in the 
SM_MON request be the path name of the export point rather the network 
address."

It was my mistake to mention that we could use "fsid" in the "my_name" 
field in previous post. As Lon pointed out, SM_MON requires server 
address so we do not blindly notify clients that could result with 
unspecified behaviors. On the other hand, the "path name" idea does 
solve various problems if we want to support different types of existing 
filesystem identifiers for failover purpose. Combining the configuration 
file mentioned in 1-2, this could be a nice long term solution. Few 
concerns (about using path name alone) :

*String comparison can be error-prone and slow
* It loses the abstraction provided by the "fsid" approach, particularly 
for a cluster filesystem load balancing purpose. With "fsid" approach, 
we could simply export the same directory using two different fsid(s) 
(associated with two different IP addresses) for various purposes on the 
same node.
* Will have to repeatedly educate users that "dev_t" is not unique 
across reboots or nodes; uuid is restricted to one single disk 
partition; and both of them require extra steps to obtain the values 
somewhere else that are not easily read by human eyes. My support 
experiences taught me that by the time users really understand the 
difference, they'll switch to fsid anyway.

1-4 [from bfields]
"Unrelated bug fix should break out from the feature patches".

Will do

2-1 [from cluster coherent NFS conf. call]
"Hooks to allow cluster filesystem does its own "start" and "stop" of 
grace period."

This could be solved by using a configuration file as described in 1-2.

3-1 [from okir]
"There's not enough room in the SM_MON request to accommodate additional 
network addresses (e.g. IPv6)".

SM_MON is sent and received *within* the very same server. Is it really 
matter whether we follow the protocol standard in this particular RPC 
call ? My guess is not. Current patch writes server IP into "my_name" 
field as a variable length character array. I see no reason this can't 
be a larger character array (say 128 bytes for IPV6) to accommodate all 
the existing network addressing we know of.

3-2 [from okir]
"Should we think about replacing SM_MON with some new design altogether 
(think netlink) ?"

Yes. But before we spend the efforts, I would suggest we focus on
1. Offering a tentative workable NFS V3 solution for our users first.
2. Check out the requirement from NFS V4 implementation so we don't end 
up revising the new changes again when V4 failover arrives.

In short, my vote is taking this (NLM) patch set and let people try it 
out while we switch our gear to look into other NFS V3 failover issues 
(nfsd in particular). Neil ?

-- Wendy


--------------070506050901040505030400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------070506050901040505030400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070506050901040505030400--
