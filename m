From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [RFC PATCH 1/3] NLM lock failover - lock release
Date: Thu, 29 Jun 2006 15:11:23 -0400
Message-ID: <76bd70e30606291211t338164adq985e43726da51e59@mail.gmail.com>
References: <44A417E7.5090500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fw1vC-0001EW-Hm
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 12:11:26 -0700
Received: from nz-out-0102.google.com ([64.233.162.199])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fw1vB-00064V-AB
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 12:11:26 -0700
Received: by nz-out-0102.google.com with SMTP id s18so251152nze
	for <nfs@lists.sourceforge.net>; Thu, 29 Jun 2006 12:11:23 -0700 (PDT)
To: "Wendy Cheng" <wcheng@redhat.com>
In-Reply-To: <44A417E7.5090500@redhat.com>
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

On 6/29/06, Wendy Cheng <wcheng@redhat.com> wrote:
> The patch piggy-backs the logic into "rq_daddr" field of struct svc_rqst
> where NFS server ip address is stored. Upon writing IPv4 address in
> standard dot notation into /proc/fs/nfsd/nlm_unlock, the logic will
> examine NLM's global nlm_files list and subsequently unlock the
> associated file if server ip address matches.
>
> Due to the size of rq_daddr (u32), we would not be able to support IPV6
> for this round of changes. Another to-do item is to enable client:server
> ip pairs to allow NFS V4 failover.

FYI: I have a patch in my IPv6 patchset that increases the size of
this field specifically in order to hold an IPv6 address.  See:

   http://oss.oracle.com/~cel/linux-2.6/2.6.17/patches/52-svc-rq_daddr.diff

for the individual patch, and surrounding patches for more context.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
