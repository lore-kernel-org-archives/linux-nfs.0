From: Bernardo Innocenti <bernie@develer.com>
Subject: Re: NFS client bug in 2.6.8-2.6.11
Date: Tue, 08 Mar 2005 10:26:09 +0100
Message-ID: <422D6FB1.4050506@develer.com>
References: <422D2FDE.2090104@develer.com>	 <1110259831.11712.1.camel@lade.trondhjem.org>	 <422D485F.5060709@develer.com> <1110264475.11712.30.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: lkml <linux-kernel@vger.kernel.org>,
	Neil Conway <nconway_kernel@yahoo.co.uk>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110264475.11712.30.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:
> ty den 08.03.2005 Klokka 07:38 (+0100) skreiv Bernardo Innocenti:
>>
>>Two clients started showing the problem after
>>being upgraded from FC2 to FC3, while the server
>>remained unchanged.
> 
> Can you produce tcpdumps to back that up?
> 
> Neil's problem appeared rather to be server-related. Neither of us could
> reproduce his problem when the server was exporting an XFS partition.

Actually, I was mistaken: running a background "find / >/dev/null"
triggers the problem even on the old RedHat (2.4.26) and
Gentoo (2.6.11) clients.


> The other thing to try is to turn off subtree checking on the server.

It's already turned off on all shares.  For the record, this is the
contents of my /etc/exportfs:

/home                   gss/krb5(rw,no_root_squash,no_subtree_check,async) beetle(rw,no_root_squash,no_subtree_check,async) deimos(rw,async,no_subtree_check,anonuid=134,anongid=100) haring(rw,async,no_subtree_check,anonuid=127,anongid=100) murphy(rw,async,no_subtree_check,anonuid=158,anongid=100) daneel(rw,async,no_subtree_check,anonuid=100,anongid=100) 10.0.0.0/8(rw,no_subtree_check,async)
/arc                    10.0.0.0/8(rw,no_root_squash,no_subtree_check,async,anonuid=14,anongid=113)

#
# NFSv4
#
/export                 beetle(rw,fsid=0,no_root_squash,insecure,no_subtree_check,async)
/export                 10.0.0.0/8(rw,fsid=0,insecure,no_subtree_check,async)
/export                 gss/krb5(rw,fsid=0,insecure,no_subtree_check,async)
/export/home            beetle(rw,nohide,no_root_squash,insecure,no_subtree_check,async)
/export/home            10.0.0.0/8(rw,nohide,insecure,no_subtree_check,async)
/export/home            gss/krb5(rw,nohide,no_root_squash,insecure,no_subtree_check,async)
/export/arc             10.0.0.0/8(rw,nohide,no_root_squash,insecure,no_subtree_check,async,anonuid=14,anongid=113)

-- 
  // Bernardo Innocenti - Develer S.r.l., R&D dept.
\X/  http://www.develer.com/
