From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH] CONFIG_NFSD_TCP actually impacts clients
Date: Fri, 30 Jun 2006 08:38:47 -0400
Message-ID: <76bd70e30606300538h6351dbffrdefe694dc99d12c7@mail.gmail.com>
References: <200606291522.46235.cablnx@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FwIGn-0004YI-FD
	for nfs@lists.sourceforge.net; Fri, 30 Jun 2006 05:38:49 -0700
Received: from nz-out-0102.google.com ([64.233.162.195])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FwIGm-0005h4-Ht
	for nfs@lists.sourceforge.net; Fri, 30 Jun 2006 05:38:49 -0700
Received: by nz-out-0102.google.com with SMTP id 40so365046nzk
	for <nfs@lists.sourceforge.net>; Fri, 30 Jun 2006 05:38:47 -0700 (PDT)
To: "Chris Abbey" <cablnx@us.ibm.com>
In-Reply-To: <200606291522.46235.cablnx@us.ibm.com>
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

Hi Chris-

On 6/29/06, Chris Abbey <cablnx@us.ibm.com> wrote:
> -config NFSD_TCP
> -       bool "Provide NFS server over TCP support"
> -       depends on NFSD
> +config NFS_TCP
> +       bool "Provide NFS services over TCP"

There's been plenty of user confusion in the past about server versus
client TCP support, so I would prefer more precise wording here.  This
new summary almost implies that the NFS client (not the lock manager)
is affected too.  How about something more specific like:

"Provide NFS and NLM server over TCP support"

Also, the name of the config option might be confusing as well...
"NFS_" is usually reserved for client-only.  I suggest NFSD_NLM_TCP.

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
